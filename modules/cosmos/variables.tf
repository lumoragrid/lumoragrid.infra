# modules/cosmos/variables.tf
# Updated to align with envs/*/main.tf module inputs

variable "name" {
  type        = string
  description = "Cosmos DB account name (globally unique)."
}

variable "location" {
  type        = string
  description = "Primary Azure region for the Cosmos DB account."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the Cosmos DB account will be created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common resource tags."
}

# Account consistency
variable "consistency_level" {
  type        = string
  default     = "Session"
  description = "Cosmos DB consistency level (Strong | BoundedStaleness | Session | ConsistentPrefix | Eventual)."
}

# Account modes
variable "serverless" {
  type        = bool
  default     = false
  description = "Deploy Cosmos DB in serverless mode (vs provisioned/Autoscale)."
}

variable "free_tier" {
  type        = bool
  default     = false
  description = "Enable Cosmos Free Tier (first 1000 RU/s and 25 GB free, where eligible)."
}

# Multi-region & failover
variable "enable_multi_region" {
  type        = bool
  default     = false
  description = "Enable multi-region read replicas."
}

variable "read_regions" {
  type        = list(string)
  default     = []
  description = "List of regions (Azure location strings) for read replicas."
}

variable "enable_automatic_failover" {
  type        = bool
  default     = true
  description = "Enable automatic failover between regions."
}

# Network access
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access to the Cosmos account."
}

# Diagnostics
variable "enable_diagnostics" {
  type        = bool
  default     = true
  description = "Enable Azure Monitor diagnostic settings."
}

variable "la_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace resource ID (required if enable_diagnostics = true)."
}

# Private endpoints
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a private endpoint for the Cosmos DB account."
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
