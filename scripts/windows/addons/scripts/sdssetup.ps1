$ErrorActionPreference = "Stop"

# Set personalization settings
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -Name WallPaper -Value "C:\Windows\web\wallpaper\Windows\img19.jpg"

# Run PowerShell 7 script
$pwshScript = "C:\parallels-tools\addons\scripts\remotedesktopmanagersource.ps1"
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"

Write-Host "Running RDM configuration with: $pwshPath -File `"$pwshScript`""

$process = Start-Process -FilePath $pwshPath -ArgumentList "-NoLogo", "-NonInteractive", "-File", "`"$pwshScript`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "RDM config script failed with exit code $($process.ExitCode)"
    exit $process.ExitCode
}

Write-Host "RDM config complete."
exit 0