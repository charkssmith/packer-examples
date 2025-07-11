<#
.SYNOPSIS
Installs GlobalProtect VPN MSI from local shared folder.
.DESCRIPTION
- Searches X:\Palo Alto\ARM for GlobalProtectARM64-*.msi
- Installs using /quiet /norestart
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " GlobalProtect VPN Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\Palo Alto\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "GlobalProtectARM64-*.msi" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No GlobalProtectARM64-*.msi installer found in $sharedFolder."
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
        Write-Error "ERROR: GlobalProtect installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    # ✅ Disable Credential Provider after successful install
    Write-Host "Disabling GlobalProtect Credential Provider..."
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{25CA8579-1BD8-469c-B9FC-6AC45A161C18}" -Name "Disabled" -Value 1

    Write-Host "GlobalProtect VPN installed and credential provider disabled successfully!"
    exit 0
}
catch {
    Write-Error "ERROR: Exception occurred during installation: $_"
    exit 1
}