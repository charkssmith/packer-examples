<#
.SYNOPSIS
Installs any GlobalProtectARM64-*.msi found in the target folder.
#>

$ErrorActionPreference = "Stop"

$installerDir = "C:\parallels-tools\VPN-Clients"

Write-Host "------------------------------------------------------------"
Write-Host " GlobalProtect VPN Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Installer Search Directory: $installerDir"
Write-Host ""

# Look for any matching MSI in the folder
$installer = Get-ChildItem -Path $installerDir -Filter "GlobalProtectARM64-*.msi" -File | Select-Object -First 1

if (!$installer) {
    Write-Error "ERROR: No GlobalProtectARM64-*.msi installer found in $installerDir."
    exit 1
}

$installerPath = $installer.FullName

Write-Host "Found Installer: $installerPath"
Write-Host ""

# Define msiexec arguments
$arguments = "/i `"$installerPath`" /quiet /norestart"

# Launch the installer
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "GlobalProtect VPN installed successfully!"
    exit 0
}
catch {
    Write-Error "Exception occurred during installation: $_"
    exit 1
}