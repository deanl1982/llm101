# AI Terms Bingo - Azure Deployment Guide

## Quick Start - Test Locally

Before deploying to Azure, you can test the bingo game locally:

1. Open `bingo.html` directly in your web browser (double-click the file)
2. That's it! No server needed for local testing.

## Azure Static Web Apps Deployment (Recommended - FREE)

Azure Static Web Apps is perfect for this simple HTML/CSS/JS application and offers a free tier.

### Option 1: Deploy via Azure Portal (Easiest)

1. **Create a Static Web App:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Click "Create a resource"
   - Search for "Static Web App"
   - Click "Create"

2. **Configure the Static Web App:**
   - **Subscription:** Select your Azure subscription
   - **Resource Group:** Create new or use existing
   - **Name:** `ai-bingo-game` (or your preferred name)
   - **Plan type:** Select "Free"
   - **Region:** Choose closest to your meeting location
   - **Deployment details:** Select "Other" (since we're not using GitHub/Azure DevOps initially)
   - Click "Review + create" then "Create"

3. **Upload your file:**
   - Once created, go to your Static Web App resource
   - In the left menu, find "Environment" or use the deployment token
   - You can drag and drop `bingo.html` directly, or use Azure CLI (see below)

### Option 2: Deploy via Azure CLI

1. **Install Azure CLI:**
   ```bash
   # Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
   ```

2. **Login to Azure:**
   ```bash
   az login
   ```

3. **Install Static Web Apps CLI:**
   ```bash
   npm install -g @azure/static-web-apps-cli
   ```

4. **Create a Static Web App:**
   ```bash
   az staticwebapp create \
     --name ai-bingo-game \
     --resource-group <your-resource-group> \
     --source . \
     --location "centralus" \
     --branch main \
     --app-location "/" \
     --output-location "." \
     --sku Free
   ```

5. **Deploy the file:**
   - Create a folder structure:
   ```
   mkdir deploy
   cp bingo.html deploy/index.html
   ```

   - Deploy using SWA CLI:
   ```bash
   cd deploy
   swa deploy --app-location . --deployment-token <your-token>
   ```

### Option 3: GitHub Integration (Most Automated)

1. **Push to GitHub:**
   ```bash
   git add bingo.html
   git commit -m "Add AI Terms Bingo game"
   git push
   ```

2. **Create Static Web App with GitHub:**
   - In Azure Portal, create Static Web App
   - Choose "GitHub" as deployment source
   - Authorize Azure to access your GitHub
   - Select your repository and branch
   - Set build configuration:
     - **App location:** `/`
     - **Output location:** leave empty
   - Azure will automatically set up GitHub Actions

3. **Update GitHub workflow (if needed):**
   - Rename `bingo.html` to `index.html` in your repo, or
   - The file will be accessible at `https://yourapp.azurestaticapps.net/bingo.html`

## Alternative: Azure Blob Storage Static Website (Also FREE within limits)

1. **Create a Storage Account:**
   ```bash
   az storage account create \
     --name aibingostorage \
     --resource-group <your-resource-group> \
     --location centralus \
     --sku Standard_LRS \
     --kind StorageV2
   ```

2. **Enable Static Website:**
   ```bash
   az storage blob service-properties update \
     --account-name aibingostorage \
     --static-website \
     --index-document index.html
   ```

3. **Upload the file:**
   - Rename `bingo.html` to `index.html`
   ```bash
   az storage blob upload \
     --account-name aibingostorage \
     --container-name '$web' \
     --name index.html \
     --file bingo.html \
     --content-type 'text/html'
   ```

4. **Get the URL:**
   ```bash
   az storage account show \
     --name aibingostorage \
     --query "primaryEndpoints.web" \
     --output tsv
   ```

## Custom Domain (Optional)

If you want a custom domain like `bingo.yourdomain.com`:

1. In your Static Web App or Storage Account, go to "Custom domains"
2. Add your domain
3. Create a CNAME record in your DNS provider pointing to the Azure URL
4. Azure will automatically provision an SSL certificate

## Sharing the Game

Once deployed, share the URL with meeting participants. They can:
1. Open the URL on any device (phone, tablet, laptop)
2. Enter their name
3. Start playing immediately

## Cost

- **Static Web Apps (Free tier):** 100GB bandwidth/month, perfect for this use case
- **Storage Account:** First 5GB free, then ~$0.02/GB/month
- **Estimated cost for your meeting:** $0 (unless you have 1000+ participants)

## Troubleshooting

- **File not found:** Make sure the file is named `index.html` or access it via `/bingo.html`
- **Not loading:** Check browser console for errors (F12)
- **Slow loading:** Azure Static Web Apps uses CDN, so first load might be slower

## Meeting Day Tips

1. Test the URL before the meeting starts
2. Share the URL in meeting chat or as a QR code
3. Keep the URL short by using a custom domain or URL shortener
4. Have participants open it before you start calling terms
