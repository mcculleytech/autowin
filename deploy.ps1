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

# SSH keygen
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519" -N "" -C "$env:USERNAME@$(hostname)"

$excludedPath = "C:\Tools"
if (-not (Test-Path $excludedPath)) {
    New-Item -ItemType Directory -Path $excludedPath -Force
}

# Add the directory to Windows Defender exclusion paths
Add-MpPreference -ExclusionPath $excludedPath

# ----------------------
# Install Apps via Chocolatey
# ----------------------
choco install -y firefox sublimetext4 7zip sysinternals wireshark obsidian git edit ghidra pebear bitwarden python visualstudio2022community

# ----------------------
# Windows Features
# ----------------------
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Invoke-Reboot   

# Install WSL 
wsl --install
wsl --set-default-version 2

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
