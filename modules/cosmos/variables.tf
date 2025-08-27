# modules/cosmos/variables.tf
# Updated to align with envs/*/main.tf module inputs

variable "name" {
  type        = string
  description = "Cosmos DB account name (3-44 lowercase, globally unique)."
}

variable "location" {
  type        = string
  description = "Primary Azure region for the Cosmos DB account."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name where the Cosmos DB account resides."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common resource tags."
}

# Mode / cost controls
variable "cosmos_serverless" {
  type        = bool
  default     = true
  description = "Enable Serverless capability (EnableServerless)."
}

variable "enable_free_tier" {
  type        = bool
  default     = true
  description = "Enable Free Tier (where eligible)."
}

# Availability / failover
variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic failover for multi-region accounts."
}

# Networking
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access (disable when using Private Endpoints only)."
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

# Private Endpoints
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a Private Endpoint for the Cosmos SQL API."
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
