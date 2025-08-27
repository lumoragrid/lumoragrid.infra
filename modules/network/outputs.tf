# modules/network/outputs.tf

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs."
  value       = { for k, s in azurerm_subnet.subnet : k => s.id }
}

output "ddos_plan_id" {
  description = "ID of the DDoS protection plan if enabled, otherwise null."
  value       = try(azurerm_network_ddos_protection_plan.ddos[0].id, null)
}
