variable "role_assignments" {
  description = "List of role assignments: principal_id, role_definition_name, scope_id"
  type = list(object({
    principal_id         = string
    role_definition_name = string
    scope_id             = string
  }))
  default = []
}
