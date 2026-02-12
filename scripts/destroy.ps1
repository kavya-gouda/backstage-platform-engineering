# Destroy Backstage and optionally AKS (PowerShell)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path $ScriptDir "..\terraform"

Set-Location $TerraformDir

Write-Host "=== Initializing Terraform ===" -ForegroundColor Cyan
terraform init

Write-Host "=== Destroying Backstage deployment and infrastructure ===" -ForegroundColor Yellow
terraform destroy

Write-Host "=== Destroy complete ===" -ForegroundColor Green
