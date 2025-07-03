Add-Type -AssemblyName PresentationFramework

for ($i = 1; $i -le 15; $i++) {
    Start-Process powershell -ArgumentList "-Command Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('SYSTEM HANGED')"
}
