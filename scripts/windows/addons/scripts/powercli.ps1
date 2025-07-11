<#
.SYNOPSIS
Installs VMware PowerCLI non-interactively on Windows.
.DESCRIPTION
- Ensures TLS 1.2
- Installs NuGet provider
- Trusts PSGallery
- Installs VMware.PowerCLI system-wide
#>

$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host " Installing VMware PowerCLI - Non-Interactive"
Write-Host "------------------------------------------------------------"

# 1️⃣ Enforce TLS 1.2
Write-Host "Forcing TLS 1.2..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2️⃣ Install NuGet provider explicitly first
Write-Host "Installing NuGet package provider..."
Install-PackageProvider -Name NuGet -Force -Scope AllUsers -Confirm:$false

# 3️⃣ Confirm NuGet is installed
Write-Host "Validating NuGet provider..."
Get-PackageProvider -Name NuGet

# 4️⃣ Register PSGallery if not found
Write-Host "Ensuring PSGallery is registered..."
if (-not (Get-PSRepository | Where-Object { $_.Name -eq "PSGallery" })) {
    Write-Host "Registering PSGallery..."
    Register-PSRepository -Default
}

# 5️⃣ Trust PSGallery to avoid prompts
Write-Host "Setting PSGallery to Trusted..."
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# 6️⃣ Install VMware PowerCLI
Write-Host "Installing VMware.PowerCLI..."
Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Confirm:$false

# 7️⃣ Disable CEIP Prompt
Write-Host "Disabling CEIP Prompt..."
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCEIP $false -Confirm:$false

Write-Host "Set Invalid Certificate Ignore..."
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

Write-Host "------------------------------------------------------------"
Write-Host " VMware PowerCLI installation complete!"
Write-Host "------------------------------------------------------------"