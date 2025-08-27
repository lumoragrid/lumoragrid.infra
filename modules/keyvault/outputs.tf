# modules/keyvault/outputs.tf

output "id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.kv.name
}

output "vault_uri" {
  description = "DNS URI of the Key Vault (for SDKs/clients)."
  value       = azurerm_key_vault.kv.vault_uri
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)."
  value       = try(azurerm_private_endpoint.pe[0].id, null)
}
