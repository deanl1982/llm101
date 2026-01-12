# AI Bingo Game - Terraform Deployment Guide

This guide explains how to deploy the AI Bingo Game to Azure using Terraform and automated deployment scripts.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Azure CLI** - [Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** (>= 1.0) - [Install Guide](https://www.terraform.io/downloads)
3. **Node.js and npm** - [Install Guide](https://nodejs.org/) (for SWA CLI)
4. **PowerShell 7+** (Windows) or **Bash** (Linux/Mac)

## Quick Start - Full Deployment

### Windows (PowerShell)

```powershell
# Make sure you're in the project directory
cd c:\GitHub-deanl1982\llm101

# Run the deployment script
.\deploy.ps1
```

### Linux/Mac (Bash)

```bash
# Make sure you're in the project directory
cd /path/to/llm101

# Make the script executable
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

The script will:
1. Check prerequisites (Azure CLI, Terraform)
2. Verify Azure login (prompt if needed)
3. Deploy Azure infrastructure (Resource Group + Static Web App)
4. Prepare website files
5. Deploy the bingo game to Azure
6. Display the live URL

## What Gets Created

The Terraform configuration creates:

- **Resource Group**: `rg-ai-bingo` (customizable)
- **Azure Static Web App**: `ai-bingo-game` (Free tier)
  - Includes global CDN
  - Automatic HTTPS
  - Custom domain support

## Configuration Options

You can customize the deployment by editing [terraform/variables.tf](terraform/variables.tf) or using command-line variables:

```bash
cd terraform

# Deploy with custom values
terraform apply \
  -var="resource_group_name=my-custom-rg" \
  -var="app_name=my-bingo-app" \
  -var="location=westus2"
```

Available variables:
- `resource_group_name` - Resource group name (default: `rg-ai-bingo`)
- `app_name` - Static Web App name (default: `ai-bingo-game`)
- `location` - Azure region (default: `eastus`)
- `environment` - Environment tag (default: `production`)

## Manual Deployment Steps

If you prefer to run steps manually:

### 1. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 2. Get Deployment Token

```bash
# Get the deployment token (needed for website deployment)
terraform output -raw deployment_token
```

### 3. Deploy Website

```bash
cd ..

# Create deployment directory
mkdir deploy
cp bingo.html deploy/index.html

# Install SWA CLI (if not already installed)
npm install -g @azure/static-web-apps-cli

# Deploy the website
cd deploy
swa deploy . --deployment-token <TOKEN_FROM_STEP_2> --env production
```

## Advanced Usage

### Redeploy Website Only (Skip Infrastructure)

If you've already deployed the infrastructure and only want to update the website:

**Windows:**
```powershell
.\deploy.ps1 -SkipTerraform
```

**Linux/Mac:**
```bash
./deploy.sh --skip-terraform
```

### Destroy All Resources

To remove all Azure resources:

**Windows:**
```powershell
.\deploy.ps1 -DestroyInfra
```

**Linux/Mac:**
```bash
./deploy.sh --destroy
```

Or manually:
```bash
cd terraform
terraform destroy
```

## Terraform State Management

The Terraform state is stored locally by default in `terraform/terraform.tfstate`. For production or team environments, consider using remote state:

### Azure Storage Backend (Recommended)

Create a backend configuration file:

```hcl
# terraform/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateXXXXX"
    container_name       = "tfstate"
    key                  = "ai-bingo.tfstate"
  }
}
```

Initialize with the backend:
```bash
terraform init -reconfigure
```

## Outputs

After deployment, Terraform provides these outputs:

- `static_web_app_url` - The live URL of your bingo game
- `static_web_app_name` - Name of the Static Web App
- `resource_group_name` - Name of the resource group
- `deployment_token` - Deployment token (sensitive)

View outputs:
```bash
cd terraform

# View all outputs
terraform output

# View specific output
terraform output static_web_app_url
```

## Cost Estimation

- **Azure Static Web Apps (Free tier)**:
  - 100 GB bandwidth per month
  - 0.5 GB storage
  - Custom domains with auto SSL
  - **Cost: $0/month**

For your meeting use case, this will be completely free unless you have thousands of participants.

## Troubleshooting

### "Azure CLI not found"
Install Azure CLI from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

### "Terraform not found"
Install Terraform from: https://www.terraform.io/downloads

### "SWA CLI not found"
The script will automatically install it, but you can install manually:
```bash
npm install -g @azure/static-web-apps-cli
```

### "Error creating Static Web App: name already exists"
Static Web App names must be globally unique. Change the `app_name` variable:
```bash
cd terraform
terraform apply -var="app_name=my-unique-bingo-app-123"
```

### "Deployment token expired"
Deployment tokens don't expire, but if you recreate the Static Web App, get the new token:
```bash
cd terraform
terraform output -raw deployment_token
```

### Permission errors
Ensure you have Contributor role on your Azure subscription:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Bingo Game

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Infrastructure
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve

      - name: Deploy Website
        run: |
          npm install -g @azure/static-web-apps-cli
          mkdir deploy
          cp bingo.html deploy/index.html
          cd deploy
          swa deploy . --deployment-token ${{ secrets.SWA_DEPLOYMENT_TOKEN }} --env production
```

## Custom Domain Setup

After deployment, add a custom domain:

1. Get your Static Web App URL:
   ```bash
   cd terraform
   terraform output static_web_app_url
   ```

2. In Azure Portal, go to your Static Web App
3. Navigate to "Custom domains"
4. Add your domain (e.g., `bingo.yourdomain.com`)
5. Create CNAME record in your DNS:
   - **Name**: `bingo`
   - **Value**: `<your-app>.azurestaticapps.net`

Azure automatically provisions a free SSL certificate.

## Meeting Day Checklist

- [ ] Deploy the application
- [ ] Test the URL in multiple browsers
- [ ] Share URL with participants (consider using a QR code)
- [ ] Have the URL ready in meeting chat
- [ ] Keep the Terraform state safe (for future updates)

## Support

For issues with:
- **Terraform**: Check [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- **Azure Static Web Apps**: Check [Azure Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- **SWA CLI**: Check [SWA CLI Docs](https://azure.github.io/static-web-apps-cli/)
