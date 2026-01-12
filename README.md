# LLM 101 - AI Terms Bingo Game

An interactive web-based bingo game for teaching AI terminology in meetings and presentations. Participants click AI terms as they're mentioned during your talk, creating an engaging learning experience.

## Project Overview

This project provides a simple, interactive bingo game where meeting participants can:
- Enter their name to personalize the experience
- Play bingo with 12 common AI terms
- Click terms as they hear them during the presentation
- Celebrate with confetti and animations when they complete all terms

### AI Terms Included

The game features 12 essential AI/ML terms:
- Machine Learning
- Neural Network
- Deep Learning
- Natural Language Processing
- Large Language Model
- Transformer
- Token
- Prompt Engineering
- Fine-tuning
- Reinforcement Learning
- Generative AI
- Embeddings

## Files in This Repository

### Core Game Files
- **[bingo.html](bingo.html)** - Self-contained bingo game (HTML/CSS/JavaScript)
- **[talk-notes.md](talk-notes.md)** - Your presentation notes

### Deployment Options

#### Manual Deployment
- **[BINGO_DEPLOYMENT.md](BINGO_DEPLOYMENT.md)** - Manual deployment guide for Azure Portal, CLI, and GitHub

#### Automated Terraform Deployment
- **[TERRAFORM_DEPLOYMENT.md](TERRAFORM_DEPLOYMENT.md)** - Complete automated deployment guide
- **[terraform/](terraform/)** - Terraform infrastructure as code
  - [main.tf](terraform/main.tf) - Azure resource definitions
  - [variables.tf](terraform/variables.tf) - Configuration variables
  - [outputs.tf](terraform/outputs.tf) - Deployment outputs (URLs, tokens)
- **[deploy.ps1](deploy.ps1)** - One-command PowerShell deployment script (Windows)
- **[deploy.sh](deploy.sh)** - One-command Bash deployment script (Linux/Mac)

### Python Scripts
- **[weights.py](weights.py)** - Weight calculation utilities
- **[weight-complex.py](weight-complex.py)** - Complex weight calculations

## Quick Start

### Option 1: Test Locally (No Deployment Needed)

Simply double-click [bingo.html](bingo.html) to open it in your browser. Perfect for testing before deployment!

### Option 2: Deploy to Azure (Automated)

Deploy the complete infrastructure and website with a single command:

**Windows:**
```powershell
.\deploy.ps1
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Create Azure Resource Group
2. Create Azure Static Web App (Free tier)
3. Deploy the bingo game
4. Provide you with the live URL

### Prerequisites for Deployment

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [Node.js/npm](https://nodejs.org/) (for SWA CLI)
- Active Azure subscription

## Architecture

**Frontend:** Single-page vanilla JavaScript application (no frameworks)
**Hosting:** Azure Static Web Apps (Free tier)
**Infrastructure:** Terraform-managed Azure resources
**Cost:** $0/month (Free tier)

## Deployment Details

### What Gets Created in Azure

- **Resource Group:** `rg-ai-bingo`
- **Static Web App:** `ai-bingo-game`
  - Global CDN distribution
  - Automatic HTTPS
  - Custom domain support
  - 100GB bandwidth/month (Free tier)

### Supported Azure Regions

Azure Static Web Apps are available in:
- `eastus2` (default)
- `westus2`
- `centralus`
- `westeurope`
- `eastasia`

## Usage During Your Meeting

1. Deploy the application before your meeting
2. Share the URL with participants (consider creating a QR code)
3. Ask participants to enter their name and open the bingo card
4. As you mention AI terms during your presentation, participants click them
5. First to complete all 12 terms gets a celebration!

## Advanced Deployment Options

### Redeploy Website Only
```powershell
# Windows
.\deploy.ps1 -SkipTerraform

# Linux/Mac
./deploy.sh --skip-terraform
```

### Destroy All Resources
```powershell
# Windows
.\deploy.ps1 -DestroyInfra

# Linux/Mac
./deploy.sh --destroy
```

### Custom Configuration
Edit [terraform/variables.tf](terraform/variables.tf) to customize:
- Resource group name
- App name
- Azure region
- Environment tags

## Documentation

- **[TERRAFORM_DEPLOYMENT.md](TERRAFORM_DEPLOYMENT.md)** - Comprehensive deployment guide
- **[BINGO_DEPLOYMENT.md](BINGO_DEPLOYMENT.md)** - Manual deployment options

## Features

- Responsive design (works on mobile, tablet, desktop)
- Progress tracking with visual progress bar
- Click to mark/unmark terms
- Winner celebration with confetti animation
- Victory sound effects
- Clean, modern UI with gradient styling

## License

This is an educational project for teaching AI concepts.

## Contributing

This is a personal project for LLM 101 presentations, but feel free to fork and customize for your own use!

