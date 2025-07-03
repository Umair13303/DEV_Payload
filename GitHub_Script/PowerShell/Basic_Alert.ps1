Add-Type @"
using System;
using System.Runtime.InteropServices;
public class UserInputBlocker {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@

# Show alert
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('SYSTEM HANGED - Input will be disabled for 50 seconds.')

# Block user input
[UserInputBlocker]::BlockInput($true)

# Wait 50 seconds
Start-Sleep -Seconds 50

# Unblock user input
[UserInputBlocker]::BlockInput($false)
