# Run from elevated PowerShell prompt
# Install boxstarter and chocolatey
# --- bootstrap.ps1 ---

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Write-Host "Installing Chocolatey..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey already installed."
}

Write-Host "Installing Boxstarter..."
if (-not (Get-Command Install-BoxstarterPackage -ErrorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
} else {
    Write-Host "Boxstarter already installed."
}

# Define where your main deployment script is located:
# You can use a local path or download it from a URL.
$mainScriptPath = "C:\Deploy\deploy.ps1"
#$mainScriptUrl = "https://yourserver.com/scripts/Main-Deploy.ps1"

# Optional: Download main script if not present locally
if (-not (Test-Path $mainScriptPath)) {
    Write-Host "Downloading main deployment script..."
    Invoke-WebRequest -Uri $mainScriptUrl -OutFile $mainScriptPath
}

Write-Host "Running main deployment script with Boxstarter..."
Install-BoxstarterPackage -PackageName $mainScriptPath

