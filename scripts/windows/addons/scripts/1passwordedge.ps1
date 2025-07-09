<#
.SYNOPSIS
Forces Microsoft Edge to install the 1Password extension for all users.
#>

$ErrorActionPreference = "Stop"

$regPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist",
    "HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\ExtensionInstallForcelist"
)

$extensionId = "dppgmdbiimibapkepcbdbmkaabgiofem"
$updateUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
$value = "$extensionId;$updateUrl"

foreach ($path in $regPaths) {
    Write-Host "------------------------------------------------------------"
    Write-Host " Setting policy in $path"
    Write-Host "------------------------------------------------------------"

    if (!(Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }

    Set-ItemProperty -Path $path -Name "1" -Value $value -Force
    Write-Host "Set policy: 1 = $value"
}

Write-Host "------------------------------------------------------------"
Write-Host "Registry configuration completed. Microsoft Edge should enforce installing the 1Password extension on next launch."