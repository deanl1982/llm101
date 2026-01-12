terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "bingo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "AI-Bingo-Game"
  }
}

# Static Web App
resource "azurerm_static_web_app" "bingo" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.bingo.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"

  tags = {
    Environment = var.environment
    Project     = "AI-Bingo-Game"
  }
}
