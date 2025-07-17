$ErrorActionPreference = "Stop"

try {
    Install-Module -Name Devolutions.PowerShell -Force -Confirm:$false -Scope AllUsers
    Import-Module -Name Devolutions.PowerShell
    $ds = Import-RDMDataSource -Path "\\Mac\Devolutions\SDS-Devolutions.rdd"
    $ds.Name = "SDS"
    Set-RDMDataSource -DataSource $ds
    Set-RDMCurrentDataSource -DataSource $ds

    Write-Host "✅ Devolutions configuration complete."
    exit 0
}
catch {
    Write-Error "❌ ERROR: $_"
    exit 1
}