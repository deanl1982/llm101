output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.bingo.default_host_name}"
}

output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.bingo.name
}

output "deployment_token" {
  description = "Deployment token for the Static Web App (sensitive)"
  value       = azurerm_static_web_app.bingo.api_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.bingo.name
}
