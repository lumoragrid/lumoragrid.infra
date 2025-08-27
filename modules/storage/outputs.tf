# modules/storage/outputs.tf

output "id" {
  description = "Resource ID of the Storage Account."
  value       = azurerm_storage_account.sa.id
}

output "name" {
  description = "Name of the Storage Account."
  value       = azurerm_storage_account.sa.name
}

output "primary_blob_endpoint" {
  description = "Primary Blob service endpoint."
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key for the Storage Account."
  value       = azurerm_storage_account.sa.primary_access_key
  sensitive   = true
}

output "connection_string" {
  description = "Primary connection string for the Storage Account."
  value       = azurerm_storage_account.sa.primary_connection_string
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint for Blob (if created)."
  value       = try(azurerm_private_endpoint.pe[0].id, null)
}

