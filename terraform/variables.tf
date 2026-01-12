variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-ai-bingo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "app_name" {
  description = "Name of the Static Web App"
  type        = string
  default     = "ai-bingo-game"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "production"
}
