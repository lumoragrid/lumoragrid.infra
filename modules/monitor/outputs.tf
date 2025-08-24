output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.law.id }
output "app_insights_connection_string" { value = azurerm_application_insights.appins.connection_string }
output "app_insights_instrumentation_key" { value = azurerm_application_insights.appins.instrumentation_key }
