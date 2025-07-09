<#
.SYNOPSIS
Downloads and installs Python from a given URL, ensuring it's on PATH.

.PARAMETER DownloadUrl
The full URL to the Python ARM64 installer.
#>

param(
    [string]$DownloadUrl = "https://www.python.org/ftp/python/3.13.5/python-3.13.5-arm64.exe"
)

$ErrorActionPreference = "Stop"

$installerDir = "C:\parallels-tools\Installers"
$installerPath = Join-Path $installerDir "python-installer-arm64.exe"

Write-Host "------------------------------------------------------------"
Write-Host " Python ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Download URL : $DownloadUrl"
Write-Host " Installer Dir: $installerDir"
Write-Host ""

# Ensure download directory exists
if (!(Test-Path $installerDir)) {
    Write-Host "Creating installer directory at $installerDir"
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

# Download installer
Write-Host "Downloading Python installer..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download completed: $installerPath"
}
catch {
    Write-Error "ERROR: Failed to download Python installer: $_"
    exit 1
}

# Install silently
$arguments = "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"

Write-Host ""
Write-Host "Installing Python silently..."
try {
    $process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Python installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "Python installed successfully."
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}

# Double-check PATH
Write-Host ""
Write-Host "Verifying PATH..."

$expectedRoot = "C:\Program Files\Python"
if (Test-Path $expectedRoot) {
    $foundVersions = Get-ChildItem -Directory $expectedRoot
    foreach ($versionDir in $foundVersions) {
        $scriptsPath = Join-Path $versionDir.FullName "Scripts"
        Write-Host "Checking: $scriptsPath"
        if (!(Get-ChildItem Env:Path | Select-String -Pattern [regex]::Escape($scriptsPath))) {
            Write-Host "Adding $scriptsPath to system PATH"
            $oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            [Environment]::SetEnvironmentVariable("Path", "$oldPath;$scriptsPath", "Machine")
        }
    }
    Write-Host "PATH updated if needed."
} else {
    Write-Host "WARNING: Expected Python install path not found. Verify manually if needed."
}

exit 0