<#
.SYNOPSIS
Installs FortiClient VPN MSI from local shared folder.
.DESCRIPTION
- Searches X:\Fortinet\ARM for FortiClient.msi
- Installs using /qn
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " FortiClient VPN Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\Fortinet\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "FortiClient.msi" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: FortiClient.msi not found in $sharedFolder."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"
Write-Host ""

# 3️⃣ Define MSI arguments
$msiArgs = "/i `"$installerPath`" /qn"

# 4️⃣ Install
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: FortiClient installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "FortiClient VPN installed successfully!"
    exit 0
}
catch {
    Write-Error "ERROR: Exception occurred during installation: $_"
    exit 1
}