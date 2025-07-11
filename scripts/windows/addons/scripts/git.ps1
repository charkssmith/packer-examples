<#
.SYNOPSIS
Finds and installs a local Git ARM64 installer from a network share,
then clones the charkssmith/scripts repo to C:\Scripts.
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Installing Git for Windows (ARM64) - Automated Unattended"
Write-Host "------------------------------------------------------------"

# ⚡ Network share location
$sourceDir = "\\Mac\Software\Git\ARM"

Write-Host "Searching in: $sourceDir"
$installer = Get-ChildItem -Path $sourceDir -Filter "Git-*arm64.exe" -File | Select-Object -First 1

if (!$installer) {
    Write-Error "ERROR: No matching Git-*arm64.exe installer found in $sourceDir."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"

# ✅ Local staging directory (optional, or install direct from share)
$localInstallerDir = "C:\parallels-tools\Installers"
if (!(Test-Path $localInstallerDir)) {
    New-Item -Path $localInstallerDir -ItemType Directory -Force | Out-Null
}

$localInstallerPath = Join-Path $localInstallerDir "Git-arm64-Setup.exe"

# Copy installer locally
Write-Host "Copying installer locally..."
Copy-Item -Path $installerPath -Destination $localInstallerPath -Force
Write-Host "Copied to: $localInstallerPath"

# ✅ Install silently
Write-Host ""
Write-Host "Running installer silently..."
Start-Process -FilePath $localInstallerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
Write-Host "Git installed successfully."

# ✅ Remove local installer
Remove-Item -Path $localInstallerPath -Force

# ✅ Refresh PATH in session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# ✅ Verify Git
try {
    $gitVersion = git --version
    Write-Host "Git version detected: $gitVersion"
} catch {
    Write-Error "ERROR: Git command not available in PATH after install."
    exit 1
}

# ✅ Clone the repo
$repoUrl  = "https://github.com/charkssmith/scripts.git"
$cloneDir = "C:\Scripts"
$repoPath = Join-Path $cloneDir "scripts"

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " Cloning repository: $repoUrl"
Write-Host "------------------------------------------------------------"

if (!(Test-Path $cloneDir)) {
    New-Item -Path $cloneDir -ItemType Directory -Force | Out-Null
}

if (Test-Path $repoPath) {
    Write-Host "Removing existing repo..."
    Remove-Item -Path $repoPath -Recurse -Force
}

git clone $repoUrl $repoPath

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " Git installation and repository cloning completed successfully."
Write-Host "------------------------------------------------------------"

exit 0