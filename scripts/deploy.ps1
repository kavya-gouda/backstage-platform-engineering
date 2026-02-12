# Deploy Backstage to AKS using Terraform (PowerShell)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path $ScriptDir "..\terraform"

Set-Location $TerraformDir

Write-Host "=== Initializing Terraform ===" -ForegroundColor Cyan
terraform init

Write-Host "=== Planning deployment ===" -ForegroundColor Cyan
terraform plan -out=tfplan

Write-Host "=== Applying deployment ===" -ForegroundColor Cyan
terraform apply tfplan

Write-Host ""
Write-Host "=== Deployment complete ===" -ForegroundColor Green
terraform output
