<#
.SYNOPSIS
Downloads and installs 1Password desktop client from a specified URL.
.PARAMETER DownloadUrl
The full URL to the 1Password ARM64 installer EXE.
#>

param(
    [string]$DownloadUrl = "https://downloads.1password.com/win/1PasswordSetup-arm64-latest.exe"
)

$ErrorActionPreference = "Stop"

$installerDir = "C:\parallels-tools\Installers"
$installerPath = Join-Path $installerDir "1password-installer-arm64.exe"

Write-Host "------------------------------------------------------------"
Write-Host " 1Password Desktop Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Download URL : $DownloadUrl"
Write-Host " Installer Dir: $installerDir"
Write-Host ""

if (!(Test-Path $installerDir)) {
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

Write-Host "Downloading 1Password installer..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
Write-Host "Download completed: $installerPath"

# ✅ Change silent argument to /S
$arguments = "--silent"

Write-Host ""
Write-Host "Installing 1Password silently..."
$process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " Installation completed with exit code: $($process.ExitCode)"
Write-Host "------------------------------------------------------------"

if ($process.ExitCode -ne 0) {
    Write-Error "ERROR: 1Password installer failed. Exit code: $($process.ExitCode)"
    exit $process.ExitCode
}

Write-Host "1Password installed successfully."
exit 0