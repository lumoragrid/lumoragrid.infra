# modules/identity/outputs.tf

output "assigned" {
  description = "Number of role assignments created."
  value       = length(azurerm_role_assignment.ra)
}

output "role_assignment_ids" {
  description = "Map of role assignment resource IDs keyed by index."
  value       = { for k, ra in azurerm_role_assignment.ra : k => ra.id }
}

output "principals" {
  description = "Map of principal IDs to roles assigned at their scopes."
  value = {
    for k, ra in azurerm_role_assignment.ra :
    k => {
      principal_id         = ra.principal_id
      role_definition_name = ra.role_definition_name
      scope                = ra.scope
    }
  }
}

