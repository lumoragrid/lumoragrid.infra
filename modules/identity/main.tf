# modules/identity/main.tf
# Provides role assignments for managed identities / service principals

resource "azurerm_role_assignment" "ra" {
  for_each = {
    for i, ra in var.role_assignments :
    i => ra
  }

  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope

  condition            = try(each.value.condition, null)
  condition_version    = try(each.value.condition_version, null)

  lifecycle {
    precondition {
      condition     = can(each.value.principal_id) && length(each.value.principal_id) > 0
      error_message = "principal_id must be provided for each role assignment."
    }
    precondition {
      condition     = can(each.value.role_definition_name) && length(each.value.role_definition_name) > 0
      error_message = "role_definition_name must be provided for each role assignment."
    }
    precondition {
      condition     = can(each.value.scope) && length(each.value.scope) > 0
      error_message = "scope must be provided for each role assignment."
    }
  }
}
