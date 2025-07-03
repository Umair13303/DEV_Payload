# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    # Relaunch the script with admin rights
    Start-Process -FilePath "powershell" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Define the user input blocker
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
