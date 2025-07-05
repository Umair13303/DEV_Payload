@echo off
:: ====================================================
:: BAT Script: Simulated Attack - Extract GuIDs from Installer table
:: Universal version for Windows 7/8/10/11/Server
:: Auto-downloads 7za.exe and MySQL
:: ====================================================

:: 1️⃣ Variables
set "DBHost=sql7.freesqldatabase.com"
set "DBPort=3306"
set "DBName=sql7788502"
set "DBUser=sql7788502"
set "DBPass=Y3jJUaTBR4"

:: MySQL ZIP
set "MySQL_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.36-winx64.zip"
set "MySQL_ZIP=mysql.zip"
set "MySQL_FOLDER=mysql"
set "MYSQL_EXE=%CD%\%MySQL_FOLDER%\bin\mysql.exe"

:: 7za
set "SevenZip_URL=https://www.7-zip.org/a/7za920.zip"
set "SevenZip_ZIP=7za.zip"
set "SevenZip_EXE=7za.exe"

:: 2️⃣ Download 7za.exe if missing
if not exist "%SevenZip_EXE%" (
    if not exist "%SevenZip_ZIP%" (
        echo [*] Downloading 7za.zip...
        bitsadmin /transfer Download7za /download /priority normal "%SevenZip_URL%" "%CD%\%SevenZip_ZIP%"
        if %errorlevel% neq 0 (
            echo [!] bitsadmin failed to download 7za.zip.
            echo [!] Please manually download:
            echo %SevenZip_URL%
            pause
            exit /b
        )
    )
    echo [*] Extracting 7za.exe...
    powershell -command "Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%SevenZip_ZIP%', '%CD%')"
)

:: 3️⃣ Verify 7za.exe
if not exist "%SevenZip_EXE%" (
    echo [!] ERROR: 7za.exe not found.
    pause
    exit /b
)

:: 4️⃣ Download MySQL ZIP if missing
if not exist "%MySQL_FOLDER%" (
    if not exist "%MySQL_ZIP%" (
        echo [*] Downloading MySQL client...
        bitsadmin /transfer DownloadMySQL /download /priority normal "%MySQL_URL%" "%CD%\%MySQL_ZIP%"
        if %errorlevel% neq 0 (
            echo [!] bitsadmin failed to download MySQL.
            echo [!] Please manually download:
            echo %MySQL_URL%
            pause
            exit /b
        )
    )
)

:: 5️⃣ Extract MySQL ZIP if folder missing
if not exist "%MySQL_FOLDER%" (
    echo [*] Extracting MySQL client...
    mkdir "%MySQL_FOLDER%"
    "%SevenZip_EXE%" x "%MySQL_ZIP%" -o"%MySQL_FOLDER%" -y >nul
)

:: 6️⃣ Verify mysql.exe
if not exist "%MYSQL_EXE%" (
    echo [!] ERROR: mysql.exe not found.
    pause
    exit /b
)

:: 7️⃣ Test connection
echo [*] Testing database connection...
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Cannot connect to database.
    pause
    exit /b
)
echo [*] Connection successful.

:: 8️⃣ Run SELECT query
echo [*] Running SELECT query...
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT Id, GuID, URL, IsActive FROM Installer WHERE IsActive=1;" > results.txt

:: 9️⃣ Display GuIDs
echo.
echo GuIDs of Active Entries:
echo ------------------------
for /f "skip=1 tokens=2 delims=	" %%G in (results.txt) do (
    echo %%G
)

echo.
echo [*] Done.
pause
