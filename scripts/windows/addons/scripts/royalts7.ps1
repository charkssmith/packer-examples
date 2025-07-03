<#
.SYNOPSIS
Downloads, installs, and licenses Royal TS ARM64 on Windows.

.PARAMETER DownloadUrl
The full URL to the latest ARM64 MSI installer.

.PARAMETER LicenseKey
Your Royal TS license key string.
#>

param(
    [string]$DownloadUrl = "https://download.royalapps.com/royalts/royaltsinstaller_7.03.50701.0_arm64.msi",
    [string]$LicenseKey  = "WG8T-CEHD-BRER-Z8BU-8RR2-2XYP-ECED-ZAY3-PU92-LGKD-D2K4-SXAG-AHA3"
)

$ErrorActionPreference = "Stop"

$installerDir  = "C:\parallels-tools\RoyalTS"
$installerPath = Join-Path $installerDir "RoyalTS-ARM64-Installer.msi"

# Create installer folder if missing
if (!(Test-Path $installerDir)) {
    Write-Host "Creating installer directory at $installerDir"
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

Write-Host "------------------------------------------------------------"
Write-Host " Royal TS ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Download URL : $DownloadUrl"
Write-Host " Installer Dir: $installerDir"
Write-Host ""

# Download the MSI
Write-Host "Downloading Royal TS installer..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download completed: $installerPath"
}
catch {
    Write-Error "ERROR: Failed to download Royal TS installer: $_"
    exit 1
}

# Install the MSI silently
$msiArgs = "/i `"$installerPath`" /quiet /norestart"

Write-Host ""
Write-Host "Installing Royal TS silently..."
try {
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop
    Write-Host "Installation finished with exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Royal TS installer failed."
        exit $process.ExitCode
    }
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}

# # Register the license key
# Write-Host ""
# Write-Host "Attempting to register license..."
# try {
#     $royalExe = "${Env:ProgramFiles}\Royal TS V7\RoyalTS.exe"

#     if (!(Test-Path $royalExe)) {
#         Write-Error "ERROR: RoyalTS.exe not found at expected path: $royalExe"
#         exit 1
#     }

#     $licenseArgs = "/registerlicense=$LicenseKey"

#     Write-Host "Running: $royalExe $licenseArgs"
#     Start-Process -FilePath $royalExe -ArgumentList $licenseArgs -Wait -PassThru -ErrorAction Stop

#     Write-Host "Royal TS licensed successfully."
#     exit 0
# }
# catch {
#     Write-Error "ERROR: Exception while registering license: $_"
#     exit 1
# }