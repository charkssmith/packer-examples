<#
.SYNOPSIS
Downloads and installs 1Password CLI from a specified ZIP URL.
.PARAMETER DownloadUrl
The full URL to the 1Password CLI ARM64 ZIP archive.
#>

param(
    [string]$DownloadUrl = "https://cache.agilebits.com/dist/1P/op2/pkg/v2.31.1/op_windows_amd64_v2.31.1.zip"
)

$ErrorActionPreference = "Stop"

$installerDir = "C:\parallels-tools\Installers"
$zipPath = Join-Path $installerDir "1password-cli-arm64.zip"
$extractDir = Join-Path $installerDir "op-cli-extracted"
$targetInstallDir = "C:\Program Files\op"

Write-Host "------------------------------------------------------------"
Write-Host " 1Password CLI Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Download URL : $DownloadUrl"
Write-Host " Installer Dir: $installerDir"
Write-Host ""

# Ensure directories exist
if (!(Test-Path $installerDir)) {
    Write-Host "Creating installer directory at $installerDir"
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

if (Test-Path $extractDir) {
    Remove-Item -Recurse -Force -Path $extractDir
}
New-Item -Path $extractDir -ItemType Directory -Force | Out-Null

# Download CLI ZIP
Write-Host "Downloading 1Password CLI..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Download completed: $zipPath"
}
catch {
    Write-Error "ERROR: Failed to download 1Password CLI: $_"
    exit 1
}

# Extract ZIP
Write-Host ""
Write-Host "Extracting 1Password CLI..."
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractDir)
    Write-Host "Extraction complete: $extractDir"
}
catch {
    Write-Error "ERROR: Failed to extract CLI ZIP: $_"
    exit 1
}

# Copy to Program Files
Write-Host ""
Write-Host "Installing CLI binary to $targetInstallDir"
if (!(Test-Path $targetInstallDir)) {
    New-Item -Path $targetInstallDir -ItemType Directory -Force | Out-Null
}

$cliExe = Get-ChildItem -Path $extractDir -Filter "op.exe" -Recurse | Select-Object -First 1
if (!$cliExe) {
    Write-Error "ERROR: op.exe not found in extracted files."
    exit 1
}

Copy-Item -Path $cliExe.FullName -Destination (Join-Path $targetInstallDir "op.exe") -Force

# Ensure PATH
Write-Host ""
Write-Host "Verifying PATH for $targetInstallDir"
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$targetInstallDir*") {
    Write-Host "Adding $targetInstallDir to system PATH"
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$targetInstallDir", "Machine")
} else {
    Write-Host "PATH already includes $targetInstallDir"
}

Write-Host "1Password CLI installed successfully."
exit 0