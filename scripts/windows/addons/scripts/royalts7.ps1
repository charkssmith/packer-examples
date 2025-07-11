<#
.SYNOPSIS
Installs Royal TS ARM64 from a mapped drive.

.DESCRIPTION
- Searches X:\RoyalTS\ARM for royaltsinstaller_*_arm64.msi
- Installs it silently with /quiet /norestart
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Royal TS ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\RoyalTS\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "royaltsinstaller_*_arm64.msi" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No royaltsinstaller_*_arm64.msi found in $sharedFolder."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"
Write-Host ""

# 3️⃣ Define msiexec arguments
$msiArgs = "/i `"$installerPath`" /quiet /norestart"

# 4️⃣ Run the installer
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Royal TS installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "Royal TS installed successfully."
    exit 0
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}