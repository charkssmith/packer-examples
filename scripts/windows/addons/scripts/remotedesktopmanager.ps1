<#
.SYNOPSIS
Installs Windows Desktop Runtime and then Devolutions Remote Desktop Manager (ARM64)
from a shared Mac folder.

.DESCRIPTION
- Searches \\Mac\Software\Devolutions\ARM for:
  - windowsdesktop-runtime*-win-arm64.exe
  - Setup.RemoteDesktopManager.win-arm64*.msi
- Installs both silently
#>

$ErrorActionPreference = "Stop"

$sourceDir = "\\Mac\Software\Devolutions\ARM"

Write-Host "------------------------------------------------------------"
Write-Host " Installing Windows Desktop Runtime + RDM"
Write-Host "------------------------------------------------------------"
Write-Host " Source Directory: $sourceDir"
Write-Host ""

if (!(Test-Path $sourceDir)) {
    Write-Error "ERROR: Source path $sourceDir not found. Is the share mounted?"
    exit 1
}

# 1️⃣ Install Windows Desktop Runtime
$runtime = Get-ChildItem -Path $sourceDir -Filter "windowsdesktop-runtime*-win-arm64.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$runtime) {
    Write-Error "ERROR: No Windows Desktop Runtime installer found."
    exit 1
}

Write-Host "Found Runtime Installer: $($runtime.FullName)"
Start-Process -FilePath $runtime.FullName -ArgumentList "/install /quiet /norestart" -Wait
Write-Host "✅ Windows Desktop Runtime installed."
Write-Host ""

# 2️⃣ Install Devolutions Remote Desktop Manager
$rdm = Get-ChildItem -Path $sourceDir -Filter "Setup.RemoteDesktopManager.win-arm64*.msi" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$rdm) {
    Write-Error "ERROR: No RDM installer found."
    exit 1
}

Write-Host "Found RDM Installer: $($rdm.FullName)"
$rdmArgs = "/i `"$($rdm.FullName)`" /quiet /norestart"

Write-Host "Starting Remote Desktop Manager installation..."
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $rdmArgs -Wait -PassThru -ErrorAction Stop

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " RDM Installation completed with exit code: $($process.ExitCode)"
Write-Host "------------------------------------------------------------"

if ($process.ExitCode -ne 0) {
    Write-Error "ERROR: RDM installer failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}

Write-Host "✅ Devolutions Remote Desktop Manager installed successfully!"
exit 0

