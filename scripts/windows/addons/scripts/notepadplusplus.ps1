<#
.SYNOPSIS
Downloads and installs Notepad++ on Windows.

.PARAMETER DownloadUrl
The full URL to the Notepad++ installer EXE.

#>

param(
    [string]$DownloadUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.8.2/npp.8.8.2.Installer.arm64.exe"
)

$ErrorActionPreference = "Stop"

$installerDir  = "C:\parallels-tools\NotepadPP"
$installerPath = Join-Path $installerDir "NotepadPP-Installer.exe"

# Create installer folder if missing
if (!(Test-Path $installerDir)) {
    Write-Host "Creating installer directory at $installerDir"
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null
}

Write-Host "------------------------------------------------------------"
Write-Host " Notepad++ Automated Installer"
Write-Host "------------------------------------------------------------"
Write-Host " Download URL : $DownloadUrl"
Write-Host " Installer Dir: $installerDir"
Write-Host ""

# Download the EXE
Write-Host "Downloading Notepad++ installer..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download completed: $installerPath"
}
catch {
    Write-Error "ERROR: Failed to download Notepad++ installer: $_"
    exit 1
}

# Install the EXE silently
$exeArgs = "/S"

Write-Host ""
Write-Host "Installing Notepad++ silently..."
try {
    $process = Start-Process -FilePath $installerPath -ArgumentList $exeArgs -Wait -PassThru -ErrorAction Stop
    Write-Host "Installation finished with exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Error "ERROR: Notepad++ installer failed."
        exit $process.ExitCode
    }

    Write-Host "Notepad++ installed successfully."
    exit 0
}
catch {
    Write-Error "ERROR: Exception during installation: $_"
    exit 1
}