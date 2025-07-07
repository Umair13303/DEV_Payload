# ===============================
# UNIVERSAL WATCHER PS1 SCRIPT
# ===============================

Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(".NET Framework 4.6.2 or later is not installed. Downloading installer...", "Dynamic Watcher")
