#!/bin/bash
# Bash deployment script for AI Bingo Game
# This script deploys the infrastructure and website to Azure

set -e

ACTION="${1:-deploy}"
SKIP_TERRAFORM=false
DESTROY_INFRA=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-terraform)
            SKIP_TERRAFORM=true
            shift
            ;;
        --destroy)
            DESTROY_INFRA=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "====================================="
echo "AI Bingo Game Deployment Script"
echo "====================================="
echo ""

# Check if Azure CLI is installed
echo "Checking prerequisites..."
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --output json | jq -r '."azure-cli"')
    echo "✓ Azure CLI installed (version $AZ_VERSION)"
else
    echo "✗ Azure CLI not found. Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Terraform is installed
if [ "$SKIP_TERRAFORM" = false ]; then
    if command -v terraform &> /dev/null; then
        TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
        echo "✓ Terraform installed (version $TF_VERSION)"
    else
        echo "✗ Terraform not found. Please install from: https://www.terraform.io/downloads"
        exit 1
    fi
fi

# Check Azure login
echo ""
echo "Checking Azure login status..."
if az account show &> /dev/null; then
    ACCOUNT_NAME=$(az account show --query "name" -o tsv)
    ACCOUNT_USER=$(az account show --query "user.name" -o tsv)
    echo "✓ Logged in to Azure as: $ACCOUNT_USER"
    echo "  Subscription: $ACCOUNT_NAME"
else
    echo "Not logged in to Azure. Logging in..."
    az login
fi

# Handle destroy action
if [ "$DESTROY_INFRA" = true ]; then
    echo ""
    echo "WARNING: This will destroy all Azure resources!"
    read -p "Type 'yes' to confirm destruction: " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Destruction cancelled."
        exit 0
    fi

    cd terraform
    terraform destroy -auto-approve
    cd ..
    echo "✓ Resources destroyed"
    exit 0
fi

# Deploy infrastructure with Terraform
if [ "$SKIP_TERRAFORM" = false ]; then
    echo ""
    echo "Deploying infrastructure with Terraform..."
    cd terraform

    echo "  Initializing Terraform..."
    terraform init

    echo "  Planning infrastructure..."
    terraform plan -out=tfplan

    echo "  Applying infrastructure..."
    terraform apply tfplan

    echo "✓ Infrastructure deployed"

    # Get outputs
    STATIC_WEB_APP_NAME=$(terraform output -raw static_web_app_name)
    DEPLOYMENT_TOKEN=$(terraform output -raw deployment_token)
    WEB_APP_URL=$(terraform output -raw static_web_app_url)
    RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)

    cd ..
else
    echo ""
    echo "Skipping Terraform (using existing infrastructure)..."

    # Try to get existing values from Terraform state
    cd terraform
    STATIC_WEB_APP_NAME=$(terraform output -raw static_web_app_name 2>/dev/null || echo "")
    DEPLOYMENT_TOKEN=$(terraform output -raw deployment_token 2>/dev/null || echo "")
    WEB_APP_URL=$(terraform output -raw static_web_app_url 2>/dev/null || echo "")
    RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
    cd ..

    if [ -z "$STATIC_WEB_APP_NAME" ]; then
        echo "✗ Could not find existing infrastructure. Run without --skip-terraform first."
        exit 1
    fi
fi

# Prepare website files
echo ""
echo "Preparing website files..."
DEPLOY_DIR="deploy"
if [ -d "$DEPLOY_DIR" ]; then
    rm -rf "$DEPLOY_DIR"
fi
mkdir -p "$DEPLOY_DIR"

# Copy bingo.html as index.html
cp bingo.html "$DEPLOY_DIR/index.html"
echo "✓ Website files prepared"

# Check if SWA CLI is installed
echo ""
echo "Checking for Azure Static Web Apps CLI..."
if command -v swa &> /dev/null; then
    SWA_VERSION=$(swa --version)
    echo "✓ SWA CLI installed (version $SWA_VERSION)"
else
    echo "✗ SWA CLI not found. Installing..."

    # Check if npm is installed
    if command -v npm &> /dev/null; then
        echo "  Installing @azure/static-web-apps-cli..."

        # Try to install globally, if that fails due to permissions, try with sudo
        if npm install -g @azure/static-web-apps-cli 2>/dev/null; then
            echo "✓ SWA CLI installed globally"
        elif sudo npm install -g @azure/static-web-apps-cli 2>/dev/null; then
            echo "✓ SWA CLI installed globally (with sudo)"
        else
            # If both fail, install locally to the project
            echo "  Global install failed, installing locally..."
            npm install @azure/static-web-apps-cli
            # Add local node_modules to PATH for this session
            export PATH="$PWD/node_modules/.bin:$PATH"
            echo "✓ SWA CLI installed locally"
        fi
    else
        echo "✗ npm not found. Please install Node.js from: https://nodejs.org/"
        exit 1
    fi
fi

# Deploy website using SWA CLI
echo ""
echo "Deploying website to Azure Static Web App..."
cd "$DEPLOY_DIR"

export SWA_CLI_DEPLOYMENT_TOKEN="$DEPLOYMENT_TOKEN"
swa deploy . --deployment-token "$DEPLOYMENT_TOKEN" --env production

cd ..

echo ""
echo "====================================="
echo "Deployment Complete!"
echo "====================================="
echo ""
echo "Your AI Bingo Game is now live at:"
echo "  $WEB_APP_URL"
echo ""
echo "Share this URL with your meeting participants!"
echo ""
echo "Resource Details:"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  Static Web App: $STATIC_WEB_APP_NAME"
echo ""
