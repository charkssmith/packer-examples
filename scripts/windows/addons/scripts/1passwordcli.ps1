<#
.SYNOPSIS
Installs 1Password CLI from local zip file in shared folder.
.DESCRIPTION
- Searches \\Mac\Software\1Password\ARM for op_windows_amd64_*.zip
- Extracts op.exe to C:\Program Files\op
- Adds C:\Program Files\op to system PATH if needed
- Closes 1Password desktop if running
- Writes settings.json to enable CLI integration
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " 1Password CLI Installer from Shared Folder"
Write-Host "------------------------------------------------------------"

# 1️⃣ Source directory
$sharedFolder = "\\Mac\Software\1Password\ARM"

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped?"
    exit 1
}

# 2️⃣ Find latest matching ZIP
$zipFile = Get-ChildItem -Path $sharedFolder -Filter "op_windows_amd64_*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $zipFile) {
    Write-Error "ERROR: No matching 1Password CLI archive found."
    exit 1
}

Write-Host "Found CLI archive: $($zipFile.FullName)"

# 3️⃣ Create temporary extract location
$tempExtractDir = Join-Path $env:TEMP "opcli-extract"
if (Test-Path $tempExtractDir) {
    Remove-Item -Recurse -Force $tempExtractDir
}
New-Item -ItemType Directory -Path $tempExtractDir | Out-Null

# 4️⃣ Extract ZIP
Write-Host "Extracting CLI to temporary directory..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile.FullName, $tempExtractDir)

# 5️⃣ Move op.exe to target directory
$targetInstallDir = "C:\Program Files\op"

if (!(Test-Path $targetInstallDir)) {
    New-Item -ItemType Directory -Path $targetInstallDir | Out-Null
}

$opExe = Get-ChildItem -Path $tempExtractDir -Filter "op.exe" -Recurse | Select-Object -First 1

if (-not $opExe) {
    Write-Error "ERROR: op.exe not found in extracted archive."
    exit 1
}

Copy-Item -Path $opExe.FullName -Destination (Join-Path $targetInstallDir "op.exe") -Force

# 6️⃣ Add install path to system PATH if not already
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$targetInstallDir*") {
    Write-Host "Adding $targetInstallDir to system PATH"
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$targetInstallDir", "Machine")
} else {
    Write-Host "System PATH already includes $targetInstallDir"
}

# 7️⃣ Cleanup
Remove-Item -Recurse -Force $tempExtractDir

# 8️⃣ Ensure 1Password Desktop is closed before writing settings
Write-Host "------------------------------------------------------------"
Write-Host " Ensuring 1Password Desktop is closed before configuring settings..."
Write-Host "------------------------------------------------------------"

$processes = Get-Process -Name "1Password" -ErrorAction SilentlyContinue

if ($processes) {
    Write-Host "Found running 1Password process(es). Attempting to close..."
    foreach ($proc in $processes) {
        try {
            $proc.CloseMainWindow() | Out-Null
        } catch {
            Write-Warning "Failed to send CloseMainWindow to PID $($proc.Id)"
        }
    }

    Start-Sleep -Seconds 5

    $stillRunning = Get-Process -Name "1Password" -ErrorAction SilentlyContinue
    if ($stillRunning) {
        Write-Warning "Some processes still running. Forcing termination..."
        $stillRunning | Stop-Process -Force
        Write-Host "Processes forcefully terminated."
    } else {
        Write-Host "Processes closed gracefully."
    }
} else {
    Write-Host "No running 1Password processes detected."
}

# 9️⃣ Write settings.json to enable CLI integration
Write-Host "------------------------------------------------------------"
Write-Host " Writing settings.json for 1Password CLI integration..."
Write-Host "------------------------------------------------------------"

$settingsDir = Join-Path $env:LOCALAPPDATA "1Password\settings"
$settingsFile = Join-Path $settingsDir "settings.json"

if (!(Test-Path $settingsDir)) {
    New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
}

$jsonContent = @'
{
  "version": 1,
  "updates.updateChannel": "PRODUCTION",
  "browsers.extension.enabled": true,
  "developers.cliSharedLockState.enabled": true,
  "security.autolock.minutes": -1,
  "security.autolock.onDeviceLock": false,
  "authTags": {
    "browsers.extension.enabled": "g3bwIGtew30E8H5ALBefzr2cMS/GbwIg3OrwLUdKHno",
    "developers.cliSharedLockState.enabled": "0WuzNrq/N/il6N5KMOFp8uKggJ65DYnZvuGfT4hNNK8",
    "security.autolock.minutes": "F0wnaD/n0zp/cBw5B4XCxpnnrZ4IWdzDA4sgRxyB+kE",
    "security.autolock.onDeviceLock": "GqAlmYYM8O8jsT8esLBYAxiZiTtAV0fhRbRvfBRqzfQ"
  }
}
'@

Set-Content -Path $settingsFile -Value $jsonContent -Encoding UTF8

Write-Host "✅ 1Password settings.json written to $settingsFile"

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host " 1Password CLI installation and integration complete."
Write-Host "------------------------------------------------------------"
exit 0