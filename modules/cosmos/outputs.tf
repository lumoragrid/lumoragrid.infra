# modules/cosmos/outputs.tf

output "id" {
  description = "Resource ID of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.acct.id
}

output "name" {
  description = "Cosmos DB account name."
  value       = azurerm_cosmosdb_account.acct.name
}

output "endpoint" {
  description = "Document endpoint of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.acct.endpoint
}

output "connection_strings" {
  description = "List of connection strings for the Cosmos DB account."
  value       = azurerm_cosmosdb_account.acct.connection_strings
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)."
  value       = try(azurerm_private_endpoint.pe[0].id, null)
}

