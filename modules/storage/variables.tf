# modules/storage/variables.tf
# Updated for clarity, consistency, and configurability

variable "name" {
  type        = string
  description = "Storage account name (must be globally unique, 3–24 lowercase alphanumeric characters)."
}

variable "location" {
  type        = string
  description = "Azure region where the storage account will be created."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name in which to create the storage account."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the storage account and related resources."
}

# ----------------------------------------------------------------------
# Account configuration
# ----------------------------------------------------------------------
variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The kind of storage account (Storage, StorageV2, BlobStorage, BlockBlobStorage, FileStorage)."
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Performance tier for the storage account (Standard or Premium)."
}

variable "replication_type" {
  type        = string
  default     = "LRS"
  description = "Replication type: LRS, GRS, RAGRS, ZRS, GZRS, RA-GZRS."
}

# ----------------------------------------------------------------------
# Networking & security
# ----------------------------------------------------------------------
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access to the storage account."
}

# ----------------------------------------------------------------------
# Diagnostics
# ----------------------------------------------------------------------
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

# ----------------------------------------------------------------------
# Data protection
# ----------------------------------------------------------------------
variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable blob versioning."
}

variable "enable_soft_delete" {
  type        = bool
  default     = true
  description = "Enable soft delete for blobs and containers (7 days retention)."
}

# ----------------------------------------------------------------------
# Private endpoints
# ----------------------------------------------------------------------
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a private endpoint for Blob storage."
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
