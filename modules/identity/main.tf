resource "azurerm_role_assignment" "ra" {
  for_each             = { for i, ra in var.role_assignments : i => ra }
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope_id
}
