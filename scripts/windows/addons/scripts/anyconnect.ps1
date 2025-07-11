<#
.SYNOPSIS
Installs Cisco AnyConnect MSI from local shared folder.
.DESCRIPTION
- Searches X:\Cisco\ARM for anyconnect-win-arm64-*-core-vpn-predeploy-k9.msi
- Installs using /quiet /norestart
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Cisco AnyConnect ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\Cisco\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "anyconnect-win-arm64-*-core-vpn-predeploy-k9.msi" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No matching AnyConnect MSI installer found in $sharedFolder."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"
Write-Host ""

# 3️⃣ Define MSI arguments
$msiArgs = "/i `"$installerPath`" /quiet /norestart"

# 4️⃣ Install
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: AnyConnect installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "Cisco AnyConnect installed successfully."
    exit 0
}
catch {
    Write-Error "ERROR: Exception occurred during installation: $_"
    exit 1
}