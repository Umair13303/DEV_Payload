@echo off
:: ====================================================
:: Universal BAT Script - Extract GuIDs from Installer table
:: Fully Self-Sufficient - No curl, tar, Expand-Archive needed
:: Robust robocopy extraction
:: ====================================================

:: 1️⃣ Database Variables
set "DBHost=sql7.freesqldatabase.com"
set "DBPort=3306"
set "DBName=sql7788502"
set "DBUser=sql7788502"
set "DBPass=Y3jJUaTBR4"

:: 2️⃣ Global Paths
set "BasePath=%APPDATA%\MySQLClient"
set "MySQL_ZIP=%BasePath%\mysql.zip"
set "MySQL_FOLDER=%BasePath%\mysql"
set "MYSQL_EXE=%MySQL_FOLDER%\bin\mysql.exe"
set "TOOLS_DIR=%BasePath%\Tools"
set "Z7_EXE=%TOOLS_DIR%\7za.exe"
set "Z7_URL=https://www.7-zip.org/a/7za920.zip"
set "Z7_ZIP=%TOOLS_DIR%\7za.zip"
set "MySQL_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.36-winx64.zip"

:: 3️⃣ Create necessary folders
if not exist "%BasePath%" mkdir "%BasePath%"
if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
if not exist "%MySQL_FOLDER%" mkdir "%MySQL_FOLDER%"

:: 4️⃣ Download 7za.exe if missing
if not exist "%Z7_EXE%" (
    echo [*] Downloading 7-Zip CLI...
    powershell -Command "Invoke-WebRequest -Uri '%Z7_URL%' -OutFile '%Z7_ZIP%'"
    powershell -Command "Expand-Archive -Path '%Z7_ZIP%' -DestinationPath '%TOOLS_DIR%' -Force"
)

:: 5️⃣ Download MySQL ZIP if needed
if not exist "%MySQL_ZIP%" (
    echo [*] Downloading MySQL ZIP...
    powershell -Command "Invoke-WebRequest -Uri '%MySQL_URL%' -OutFile '%MySQL_ZIP%'"
)

:: 6️⃣ Extract MySQL using 7za.exe and fix folder structure
if not exist "%MYSQL_EXE%" (
    echo [*] Extracting MySQL ZIP using 7za.exe...
    "%Z7_EXE%" x "%MySQL_ZIP%" -o"%MySQL_FOLDER%" -y >nul

    echo [*] Moving extracted MySQL files into place using robocopy...
    robocopy "%MySQL_FOLDER%\mysql-8.0.36-winx64" "%MySQL_FOLDER%" /E /MOVE >nul
    rmdir "%MySQL_FOLDER%\mysql-8.0.36-winx64" >nul 2>&1
)

:: 7️⃣ Check MySQL binary
if not exist "%MYSQL_EXE%" (
    echo [!] ERROR: mysql.exe not found even after extraction.
    pause
    exit /b
)

:: 8️⃣ Test DB connection
echo [*] Testing connection to database...
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Cannot connect to MySQL.
    pause
    exit /b
)
echo [*] Connection successful.

:: 9️⃣ Run query and save result
set "RESULT_FILE=%BasePath%\results.txt"
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT Id, GuID, URL, IsActive FROM Installer WHERE IsActive=TRUE;" > "%RESULT_FILE%"

:: 🔟 Display GuIDs
echo.
echo GuIDs of Active Entries:
echo ------------------------
for /f "skip=1 tokens=2 delims=	" %%G in (%RESULT_FILE%) do (
    echo %%G
)

echo.
echo [*] Done.
pause
