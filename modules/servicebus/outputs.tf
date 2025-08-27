# modules/servicebus/outputs.tf

output "id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.ns.id
}

output "name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.ns.name
}

output "queues" {
  description = "Map of created queue names to IDs."
  value       = { for k, q in azurerm_servicebus_queue.q : k => q.id }
}

output "topics" {
  description = "Map of created topic names to IDs."
  value       = { for k, t in azurerm_servicebus_topic.t : k => t.id }
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)."
  value       = try(azurerm_private_endpoint.pe[0].id, null)
}
