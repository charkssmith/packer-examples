<#
.SYNOPSIS
Installs 1Password desktop client from local shared drive.
.DESCRIPTION
- Searches X:\1Password\ARM for 1PasswordSetup-arm64-latest.exe
- Installs using --silent
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " 1Password Desktop Installer from Shared Drive"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define source directory (mapped drive)
$sourceDir = "\\Mac\Software\1Password\ARM"

if (!(Test-Path $sourceDir)) {
    Write-Error "ERROR: Shared folder $sourceDir not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Find installer matching pattern
$installer = Get-ChildItem -Path $sourceDir -Filter "1PasswordSetup-arm64-latest.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No installer matching '1PasswordSetup-arm64-latest.exe' found in $sourceDir"
    exit 1
}

Write-Host "Found installer: $($installer.FullName)"

# 3️⃣ Copy installer to local VM (optional staging folder)
$installerDir = "C:\parallels-tools\Installers"

if (!(Test-Path $installerDir)) {
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

$localInstallerPath = Join-Path -Path $installerDir -ChildPath "1PasswordInstaller-arm64.exe"
Copy-Item -Path $installer.FullName -Destination $localInstallerPath -Force

Write-Host "Copied installer to local staging: $localInstallerPath"

# 4️⃣ Install silently
$arguments = "--silent"

Write-Host "Running silent installation..."
$process = Start-Process -FilePath $localInstallerPath -ArgumentList $arguments -Wait -PassThru

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