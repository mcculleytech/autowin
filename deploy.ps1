# ----------------------
# Core Settings
# ----------------------
Disable-UAC           # Disable User Account Control (optional)
Enable-RemoteDesktop   # Enable RDP
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions
Disable-GameBarTips

# ----------------------
# System Config
# ----------------------
Rename-Computer -NewName "ganado"
Set-TimeZone "Central Standard Time"

# Force 24-hour (HH:mm) format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss"

# ----------------------
# Taskbar Cleanup
# ----------------------

# Remove Widgets
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarDa -Value 0

# Remove Search
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0

# Remove Task View
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Value 0

# Remove Chat
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarMn -Value 0

# Remove Copilot (Windows 11)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCopilotButton -Value 0

# Remove Microsoft Store pinned icon only (unpin without affecting other icons)
$shell = New-Object -ComObject Shell.Application
$store = $shell.Namespace('shell:AppsFolder').ParseName('Microsoft.WindowsStore_8wekyb3d8bbwe!App')
$verb = $store.Verbs() | Where-Object { $_.Name.Replace('&','') -match 'Unpin from taskbar' }
if ($verb) { $verb.DoIt() }

# ----------------------
# Pin Apps to Taskbar
# ----------------------

Function Pin-AppToTaskbar {
    param([string]$AppName)
    $shell = New-Object -ComObject Shell.Application
    $app = $shell.Namespace('shell:AppsFolder').Items() | Where-Object { $_.Name -eq $AppName }
    if ($app) {
        $verb = $app.Verbs() | Where-Object { $_.Name.Replace('&','') -match 'Pin to taskbar' }
        if ($verb) { $verb.DoIt() }
    }
}

# Pin Firefox
Pin-AppToTaskbar "Mozilla Firefox"

# Pin Sublime Text
Pin-AppToTaskbar "Sublime Text"

# Pin Obsidian
Pin-AppToTaskbar "Obsidian"

# Pin Ubuntu (WSL)
Pin-AppToTaskbar "Ubuntu"

# ----------------------
# Setup excluded dir from Defender
# ----------------------

$excludedPath = "C:\Tools"
if (-not (Test-Path $excludedPath)) {
    New-Item -ItemType Directory -Path $excludedPath -Force
}

# Add the directory to Windows Defender exclusion paths
Add-MpPreference -ExclusionPath $excludedPath

# ----------------------
# Install Apps via Chocolatey
# ----------------------
choco install -y firefox sublimetext4 7zip processhacker wireshark obsidian git edit ghidra pebear bitwarden python visualstudio2022community
# sysinternals checksum woes
choco install -y sysinternals --ignore-checksum

# ----------------------
# Windows Features
# ----------------------
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# ----------------------
# Install RSAT (Remote Server Administration Tools)
# ----------------------

# Core RSAT (AD, DHCP, DNS, Group Policy)
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

# (Optional) Additional RSAT components
Add-WindowsCapability -Online -Name Rsat.FileServices.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.Print.Management.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0

# ----------------------
# WSL Install (AFTER REBOOT)
# ----------------------
if (-not (wsl --status 2>$null)) {
    wsl --install
    wsl --set-default-version 2
}

#----------------------
# Install Compiled Tools
#----------------------
$ghostPackDir = "C:\Tools\GhostPack"

if (-not (Test-Path $ghostPackDir)) {
    git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git $ghostPackDir
} else {
    Set-Location $ghostPackDir
    git pull
}

# ----------------------
# Domain Join (optional)
# ----------------------
# Add-Computer -DomainName "corp.local" -Credential (Get-Credential) -Restart

# ----------------------
# Cleanup
# ----------------------
Remove-Item "$env:Public\Desktop\*.lnk" -Force -ErrorAction SilentlyContinue
