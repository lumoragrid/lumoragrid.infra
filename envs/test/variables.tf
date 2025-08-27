# envs/test/variables.tf
# Common variables for the Test environment (multi-region, security-first)

# ----------------------------------------------------------------------
# Identifiers / Azure context
# ----------------------------------------------------------------------
variable "project" {
  type        = string
  description = "Project code / name used in resource names (e.g., lumoragrid)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev|test|uat|prod)"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID (for identity & RBAC wiring)"
}

# ----------------------------------------------------------------------
# Regions (map-of-objects shape with network & feature toggles)
# ----------------------------------------------------------------------
variable "regions" {
  description = "Per-region configuration (location, addressing, and per-service toggles)."
  type = map(object({
    location      = string
    address_space = string
    subnets = object({
      apps = string
      pe   = string
    })
    ddos_enabled      = optional(bool, true)
    firewall_enabled  = optional(bool, true)
    enable_storage    = optional(bool, true)
    enable_servicebus = optional(bool, true)
    enable_cosmos     = optional(bool, true)
    enable_keyvault   = optional(bool, true)
  }))
}

# Additional free-form tags applied to all resources
variable "tags" {
  type        = map(string)
  description = "Base tags applied to all resources in this environment"
  default     = {}
}

# ----------------------------------------------------------------------
# Security / diagnostics feature flags
# ----------------------------------------------------------------------
variable "enable_private_endpoints" {
  type        = bool
  description = "Enable Private Endpoints for PaaS resources (Storage/Cosmos/SB/etc.)"
  default     = true
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostics to Log Analytics for supported resources"
  default     = true
}

# ----------------------------------------------------------------------
# Service Bus configuration
# ----------------------------------------------------------------------
variable "servicebus_sku" {
  type        = string
  description = "Service Bus SKU (Standard | Premium)"
  default     = "Premium"
}

variable "sb_capacity" {
  type        = number
  description = "Service Bus capacity/Messaging Units (Premium only: 1,2,4). Use 0 for Standard."
  default     = 1
}

variable "ip_allowlist" {
  type        = list(string)
  description = "Public IPs/CIDRs allowed at network ACLs (if applicable). Use Private Endpoints for production."
  default     = []
}

# ----------------------------------------------------------------------
# Cosmos DB configuration
# ----------------------------------------------------------------------
variable "cosmos_consistency_level" {
  type        = string
  description = "Cosmos DB consistency (Strong | BoundedStaleness | Session | ConsistentPrefix | Eventual)"
  default     = "Session"
}

variable "cosmos_serverless" {
  type        = bool
  description = "Deploy Cosmos DB in Serverless mode (vs provisioned/Autoscale)"
  default     = false
}

variable "cosmos_enable_free_tier" {
  type        = bool
  description = "Enable Cosmos Free Tier (first 1000 RU/s and 25 GB are free per account, where eligible)"
  default     = false
}

# ----------------------------------------------------------------------
# Log Analytics configuration
# ----------------------------------------------------------------------
variable "law_sku" {
  type        = string
  description = "Log Analytics Workspace SKU (PerGB2018 | Free)"
  default     = "PerGB2018"
}

variable "retention_days" {
  type        = number
  description = "Retention for legacy consumers (ignored if law_sku == Free). Prefer 'log_analytics_retention_days'."
  default     = 30
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Retention (days) for Log Analytics workspaces created by this env"
  default     = 30
}

# ----------------------------------------------------------------------
# SQL admin (login and password; password comes from Key Vault/Variable Group)
# ----------------------------------------------------------------------
variable "sql_admin_login" {
  type        = string
  description = "SQL administrator login"
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL administrator password (provided via Key Vault/Variable Group)"
  sensitive   = true
}

