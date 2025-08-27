# modules/identity/variables.tf
# Updated to align with main.tf changes (scope instead of scope_id, optional conditions)

variable "role_assignments" {
  description = <<-DESC
    List of role assignments to create. Each object requires:
      - principal_id: The object ID of the principal (user, group, or managed identity).
      - role_definition_name: The RBAC role to assign (e.g., 'Reader', 'Contributor').
      - scope: The scope at which the role applies (subscription, RG, or resource).
    Optional:
      - condition: (optional) A condition expression for the role assignment.
      - condition_version: (optional) Version of the condition (default: '2.0').
  DESC

  type = list(object({
    principal_id         = string
    role_definition_name = string
    scope                = string
    condition            = optional(string)
    condition_version    = optional(string, "2.0")
  }))

  default = []
}
