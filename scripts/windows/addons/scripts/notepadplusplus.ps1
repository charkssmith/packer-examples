<#
.SYNOPSIS
Installs Notepad++ from a local shared folder.
.DESCRIPTION
- Searches X:\NPP\ARM for npp.*Installer.arm64.exe
- Installs using /S
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Notepad++ ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\NPP\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "npp.*Installer.arm64.exe" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No Notepad++ installer matching 'npp.*Installer.arm64.exe' found in $sharedFolder."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"
Write-Host ""

# 3️⃣ Define installer arguments
$exeArgs = "/S"

# 4️⃣ Install
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath $installerPath -ArgumentList $exeArgs -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Notepad++ installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "Notepad++ installed successfully."
    exit 0
}
catch {
    Write-Error "ERROR: Exception occurred during installation: $_"
    exit 1
}