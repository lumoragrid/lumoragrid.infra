# modules/monitor/outputs.tf

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.law.name
}

output "app_insights_id" {
  description = "Resource ID of the Application Insights instance."
  value       = azurerm_application_insights.appins.id
}

output "app_insights_connection_string" {
  description = "Connection string for Application Insights (used by apps/SDKs)."
  value       = azurerm_application_insights.appins.connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights (legacy use only)."
  value       = azurerm_application_insights.appins.instrumentation_key
  sensitive   = true
}
