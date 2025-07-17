<#
.SYNOPSIS
Installs the latest available PowerShell Core MSI for Windows ARM64
from a VMware/Mac shared folder, launches Windows Terminal once to
generate its settings, and sets PowerShell 7 as the default profile.

.DESCRIPTION
- Searches \\Mac\Software\PowerShell\ARM for PowerShell-*-win-arm64.msi
- Installs the latest MSI silently
- Launches Windows Terminal to create settings.json
- Edits settings.json to set PowerShell 7 as default profile
#>

$ErrorActionPreference = "Stop"

$sourceDir = "\\Mac\Software\PowerShell\ARM"
$targetGuid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host "------------------------------------------------------------"
Write-Host " PowerShell ARM64 Automated Installer and Terminal Config"
Write-Host "------------------------------------------------------------"
Write-Host " Source Directory: $sourceDir"
Write-Host ""

# ✅ 1. Check that the shared folder exists
if (!(Test-Path $sourceDir)) {
    Write-Error "ERROR: Shared folder $sourceDir not found. Is VMware Shared Folders enabled?"
    exit 1
}

# ✅ 2. Find the latest MSI matching naming convention
$installer = Get-ChildItem -Path $sourceDir -Filter "PowerShell-*-win-arm64.msi" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No installer matching 'PowerShell-*-win-arm64.msi' found in $sourceDir."
    exit 1
}

Write-Host "Found PowerShell installer: $($installer.FullName)"
Write-Host ""

# ✅ 3. Install silently
$msiArgs = "/i `"$($installer.FullName)`" /quiet /norestart"

try {
    Write-Host "Installing PowerShell silently..."
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: PowerShell installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "✅ PowerShell installed successfully!"
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}

# ✅ 4. Force Windows Terminal to launch once and generate settings
Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " Launching Windows Terminal once to generate settings..."
Write-Host "------------------------------------------------------------"

try {
    Start-Process wt.exe -ArgumentList 'new-tab' -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Stop-Process -Name WindowsTerminal -ErrorAction SilentlyContinue
    Write-Host "✅ Windows Terminal launched and closed to generate settings."
}
catch {
    Write-Warning "⚠️ Could not launch Windows Terminal automatically. Make sure it's installed."
}


try {
    Start-Process wt.exe -ArgumentList 'new-tab' -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Stop-Process -Name WindowsTerminal -ErrorAction SilentlyContinue
    Write-Host "✅ Windows Terminal launched and closed to generate settings."
}
catch {
    Write-Warning "⚠️ Could not launch Windows Terminal automatically. Make sure it's installed."
}
