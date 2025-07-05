@echo off
:: ====================================================
:: BAT Script: Simulated Attack - Extract GuIDs from Installer table
:: ====================================================

:: 1️⃣ Variables
set "DBHost=sql7.freesqldatabase.com"
set "DBPort=3306"
set "DBName=sql7788502"
set "DBUser=sql7788502"
set "DBPass=Y3jJUaTBR4"

:: MySQL ZIP URL (official, stable)
set "MySQL_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.36-winx64.zip"
set "MySQL_ZIP=mysql.zip"
set "MySQL_FOLDER=mysql"
set "MYSQL_EXE=%CD%\%MySQL_FOLDER%\bin\mysql.exe"

:: 2️⃣ Download MySQL ZIP only if folder and ZIP are missing
if not exist "%MySQL_FOLDER%" (
    if not exist "%MySQL_ZIP%" (
        echo [*] Downloading MySQL client with bitsadmin...
        bitsadmin /transfer DownloadMySQL /download /priority normal "%MySQL_URL%" "%CD%\%MySQL_ZIP%"
        if %errorlevel% neq 0 (
            echo [!] bitsadmin failed, trying curl...
            curl -L -o "%MySQL_ZIP%" "%MySQL_URL%"
        )
    )
)

:: 3️⃣ Extract ZIP if folder doesn't exist
if not exist "%MySQL_FOLDER%" (
    echo [*] Extracting MySQL client...
    mkdir "%MySQL_FOLDER%"
    tar -xf "%MySQL_ZIP%" -C "%MySQL_FOLDER%" --strip-components=1
)

:: 4️⃣ Verify mysql.exe
if not exist "%MYSQL_EXE%" (
    echo [!] ERROR: mysql.exe not found.
    pause
    exit /b
)

:: 5️⃣ Test connection
echo [*] Testing database connection...
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Cannot connect to database.
    pause
    exit /b
)
echo [*] Connection successful.

:: 6️⃣ Run the target query and save output
echo [*] Running SELECT query...
"%MYSQL_EXE%" -h %DBHost% -P %DBPort% -u %DBUser% -p%DBPass% -D %DBName% -e "SELECT Id, GuID, URL, IsActive FROM Installer WHERE IsActive=TRUE;" > results.txt

:: 7️⃣ Loop results and display GuID only
echo.
echo GuIDs of Active Entries:
echo ------------------------
for /f "skip=1 tokens=2 delims=	" %%G in (results.txt) do (
    echo %%G
)

echo.
echo [*] Done.
pause
