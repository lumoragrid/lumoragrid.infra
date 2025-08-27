# modules/keyvault/variables.tf
# Updated for consistency and clarity with other modules

variable "name" {
  type        = string
  description = "Key Vault name (must be globally unique across Azure)."
}

variable "location" {
  type        = string
  description = "Azure region where the Key Vault will be created."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the Key Vault."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID used for Key Vault access policies and RBAC."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to the Key Vault."
}

# Network access
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is enabled for the Key Vault."
}

# Security settings
variable "enable_purge_protection" {
  type        = bool
  default     = true
  description = "Enable purge protection to prevent accidental or malicious permanent deletion."
}

# Private endpoints
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a private endpoint for the Key Vault."
}

variable "pe_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint (required if enable_private_endpoints = true)."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs to link with the private endpoint."
}

# Diagnostics
variable "enable_diagnostics" {
  type        = bool
  default     = true
  description = "Enable diagnostics and send metrics/logs to Log Analytics."
}

variable "la_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace resource ID (required when enable_diagnostics = true)."
}
