Add-Type -AssemblyName PresentationFramework

for ($i = 1; $i -le 15; $i++) {
    [System.Windows.MessageBox]::Show("SYSTEM HANGED - Alert $i of 15")
}
