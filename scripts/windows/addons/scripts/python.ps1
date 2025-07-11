<#
.SYNOPSIS
Installs Python ARM64 from a local shared folder.
.DESCRIPTION
- Searches X:\NPP\ARM for python-*-arm64.exe
- Installs with silent arguments
- Adds Scripts folder to system PATH
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Python ARM64 Automated Installer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Define shared folder path
$sharedFolder = "\\Mac\Software\Python\ARM"

Write-Host " Installer Search Directory: $sharedFolder"
Write-Host ""

if (!(Test-Path $sharedFolder)) {
    Write-Error "ERROR: Shared folder $sharedFolder not found. Is the drive mapped correctly?"
    exit 1
}

# 2️⃣ Locate the installer
$installer = Get-ChildItem -Path $sharedFolder -Filter "python-*-arm64.exe" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $installer) {
    Write-Error "ERROR: No python-*-arm64.exe installer found in $sharedFolder."
    exit 1
}

$installerPath = $installer.FullName
Write-Host "Found Installer: $installerPath"
Write-Host ""

# 3️⃣ Define installer arguments
$arguments = "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"

# 4️⃣ Run the installer
try {
    Write-Host "Starting silent installation..."
    $process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru -ErrorAction Stop

    Write-Host ""
    Write-Host "------------------------------------------------------------"
    Write-Host " Installation completed with exit code: $($process.ExitCode)"
    Write-Host "------------------------------------------------------------"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Python installer failed. Exit code: $($process.ExitCode)"
        exit $process.ExitCode
    }

    Write-Host "Python installed successfully."
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}

# 5️⃣ Ensure Python Scripts path is added to system PATH
Write-Host ""
Write-Host "Verifying and updating PATH..."

$expectedRoot = "C:\Program Files\Python"
if (Test-Path $expectedRoot) {
    $foundVersions = Get-ChildItem -Directory $expectedRoot
    foreach ($versionDir in $foundVersions) {
        $scriptsPath = Join-Path $versionDir.FullName "Scripts"
        if (!(Get-ChildItem Env:Path | Select-String -Pattern [regex]::Escape($scriptsPath))) {
            Write-Host "Adding $scriptsPath to system PATH"
            $oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            [Environment]::SetEnvironmentVariable("Path", "$oldPath;$scriptsPath", "Machine")
        }
    }
    Write-Host "PATH updated if needed."
} else {
    Write-Host "WARNING: Expected Python install path not found. Verify manually if needed."
}

exit 0