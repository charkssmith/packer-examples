$ErrorActionPreference = "Stop"

Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;
Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -name WallPaper -value C:\Windows\web\wallpaper\Windows\img19.jpg
