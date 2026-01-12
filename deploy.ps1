# PowerShell deployment script for AI Bingo Game
# This script deploys the infrastructure and website to Azure

param(
    [string]$Action = "deploy",
    [switch]$SkipTerraform = $false,
    [switch]$DestroyInfra = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AI Bingo Game Deployment Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json 2>$null | ConvertFrom-Json
    Write-Host "✓ Azure CLI installed (version $($azVersion.'azure-cli'))" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI not found. Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Check if Terraform is installed
if (-not $SkipTerraform) {
    try {
        $tfVersion = terraform version -json | ConvertFrom-Json
        Write-Host "✓ Terraform installed (version $($tfVersion.terraform_version))" -ForegroundColor Green
    } catch {
        Write-Host "✗ Terraform not found. Please install from: https://www.terraform.io/downloads" -ForegroundColor Red
        exit 1
    }
}

# Check Azure login
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Not logged in to Azure. Logging in..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
}
Write-Host "✓ Logged in to Azure as: $($account.user.name)" -ForegroundColor Green
Write-Host "  Subscription: $($account.name) ($($account.id))" -ForegroundColor Gray

# Handle destroy action
if ($DestroyInfra) {
    Write-Host ""
    Write-Host "WARNING: This will destroy all Azure resources!" -ForegroundColor Red
    $confirm = Read-Host "Type 'yes' to confirm destruction"
    if ($confirm -ne "yes") {
        Write-Host "Destruction cancelled." -ForegroundColor Yellow
        exit 0
    }

    Push-Location terraform
    terraform destroy -auto-approve
    Pop-Location
    Write-Host "✓ Resources destroyed" -ForegroundColor Green
    exit 0
}

# Deploy infrastructure with Terraform
if (-not $SkipTerraform) {
    Write-Host ""
    Write-Host "Deploying infrastructure with Terraform..." -ForegroundColor Yellow
    Push-Location terraform

    Write-Host "  Initializing Terraform..." -ForegroundColor Gray
    terraform init

    Write-Host "  Planning infrastructure..." -ForegroundColor Gray
    terraform plan -out=tfplan

    Write-Host "  Applying infrastructure..." -ForegroundColor Gray
    terraform apply tfplan

    Write-Host "✓ Infrastructure deployed" -ForegroundColor Green

    # Get outputs
    $staticWebAppName = terraform output -raw static_web_app_name
    $deploymentToken = terraform output -raw deployment_token
    $webAppUrl = terraform output -raw static_web_app_url
    $resourceGroupName = terraform output -raw resource_group_name

    Pop-Location
} else {
    Write-Host ""
    Write-Host "Skipping Terraform (using existing infrastructure)..." -ForegroundColor Yellow

    # Try to get existing values from Terraform state
    Push-Location terraform
    $staticWebAppName = terraform output -raw static_web_app_name 2>$null
    $deploymentToken = terraform output -raw deployment_token 2>$null
    $webAppUrl = terraform output -raw static_web_app_url 2>$null
    $resourceGroupName = terraform output -raw resource_group_name 2>$null
    Pop-Location

    if (-not $staticWebAppName) {
        Write-Host "✗ Could not find existing infrastructure. Run without -SkipTerraform first." -ForegroundColor Red
        exit 1
    }
}

# Prepare website files
Write-Host ""
Write-Host "Preparing website files..." -ForegroundColor Yellow
$deployDir = "deploy"
if (Test-Path $deployDir) {
    Remove-Item -Path $deployDir -Recurse -Force
}
New-Item -ItemType Directory -Path $deployDir | Out-Null

# Copy bingo.html as index.html
Copy-Item -Path "bingo.html" -Destination "$deployDir/index.html"
Write-Host "✓ Website files prepared" -ForegroundColor Green

# Check if SWA CLI is installed
Write-Host ""
Write-Host "Checking for Azure Static Web Apps CLI..." -ForegroundColor Yellow
$swaInstalled = $false
try {
    $swaCheck = Get-Command swa -ErrorAction SilentlyContinue
    if ($swaCheck) {
        $swaVersion = & swa --version 2>$null
        Write-Host "✓ SWA CLI installed (version $swaVersion)" -ForegroundColor Green
        $swaInstalled = $true
    }
} catch {
    # SWA not found
}

if (-not $swaInstalled) {
    Write-Host "✗ SWA CLI not found. Installing..." -ForegroundColor Yellow

    # Check if npm is installed
    try {
        $null = Get-Command npm -ErrorAction Stop
        Write-Host "  Installing @azure/static-web-apps-cli..." -ForegroundColor Gray
        npm install -g @azure/static-web-apps-cli
        Write-Host "✓ SWA CLI installed" -ForegroundColor Green
    } catch {
        Write-Host "✗ npm not found. Please install Node.js from: https://nodejs.org/" -ForegroundColor Red
        exit 1
    }
}

# Deploy website using SWA CLI
Write-Host ""
Write-Host "Deploying website to Azure Static Web App..." -ForegroundColor Yellow
Push-Location $deployDir

$env:SWA_CLI_DEPLOYMENT_TOKEN = $deploymentToken
swa deploy . --deployment-token $deploymentToken --env production

Pop-Location

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your AI Bingo Game is now live at:" -ForegroundColor Cyan
Write-Host "  $webAppUrl" -ForegroundColor White -BackgroundColor Blue
Write-Host ""
Write-Host "Share this URL with your meeting participants!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Resource Details:" -ForegroundColor Gray
Write-Host "  Resource Group: $resourceGroupName" -ForegroundColor Gray
Write-Host "  Static Web App: $staticWebAppName" -ForegroundColor Gray
Write-Host ""
