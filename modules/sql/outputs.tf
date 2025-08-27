# modules/sql/outputs.tf

output "server_id" {
  description = "Resource ID of the SQL Server."
  value       = azurerm_mssql_server.server.id
}

output "server_name" {
  description = "Name of the SQL Server."
  value       = azurerm_mssql_server.server.name
}

output "db_id" {
  description = "Resource ID of the SQL Database."
  value       = azurerm_mssql_database.db.id
}

output "db_name" {
  description = "Name of the SQL Database."
  value       = azurerm_mssql_database.db.name
}

output "private_endpoint_id" {
  description = "ID of the private endpoint for SQL Server (if created)."
  value       = try(azurerm_private_endpoint.pe[0].id, null)
}
