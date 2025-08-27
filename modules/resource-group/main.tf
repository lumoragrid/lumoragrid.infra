# modules/resource-group/main.tf
# Resource Group module with security-first defaults and validations

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    precondition {
      condition     = can(var.name) && length(var.name) > 0
      error_message = "Resource group name must not be empty."
    }
    precondition {
      condition     = can(var.location) && length(var.location) > 0
      error_message = "Resource group location must not be empty."
    }
  }
}
