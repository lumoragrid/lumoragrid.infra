# modules/storage/variables.tf
# (Save this file as UTF-8 with LF line endings)

variable "account_name" {
  type        = string
  description = "Storage account name (3-24 lowercase alphanumeric). Must be globally unique."
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.account_name))
    error_message = "account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "rg_name" {
  type        = string
  description = "Resource group name."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags."
}

# Networking / access
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Enable public network access (disable when using Private Endpoints)."
}

# Diagnostics
variable "enable_diagnostics" {
  type        = bool
  default     = true
  description = "Create diagnostic setting to Log Analytics."
}

variable "la_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace resource ID (required if enable_diagnostics = true)."
}

# Data protection
variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable blob versioning."
}

variable "enable_soft_delete" {
  type        = bool
  default     = true
  description = "Enable delete retention for blobs/containers (7 days)."
}

# Private endpoints
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a Private Endpoint for the 'blob' subresource."
}

variable "pe_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the Private Endpoint (required when enable_private_endpoints = true)."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs to link when creating a Private Endpoint."
}

# New (align with env main.tf)
variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "Storage account kind (e.g., StorageV2)."
}

variable "replication_type" {
  type        = string
  default     = "LRS"
  description = "Replication (LRS|ZRS|GRS|GZRS|RAGRS|RA-GZRS)."
}
