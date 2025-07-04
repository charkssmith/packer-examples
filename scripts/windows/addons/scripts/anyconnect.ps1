<#
.SYNOPSIS
Installs any Cisco AnyConnect MSI matching anyconnect-win-arm64-4*.msi in the target folder.
#>

$ErrorActionPreference = "Stop"

$installerDir = "C:\parallels-tools\VPN-Clients"

Write-Host "------------------------------------------------------------"
Write-Host " Cisco AnyConnect ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Installer Search Directory: $installerDir"
Write-Host ""

# Look for any matching MSI in the folder
$installer = Get-ChildItem -Path $installerDir -Filter "anyconnect-win-arm64-4*.msi" -File | Select-Object -First 1

if (!$installer) {
    Write-Error "ERROR: No anyconnect-win-arm64-4*.msi installer found in $installerDir."
    exit 1
}

$installerPath = $installer.FullName

Write-Host "Found Installer: $installerPath"
Write-Host ""

# Define msiexec arguments
$msiArgs = "/i `"$installerPath`" /quiet /norestart"

# Launch the installer
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