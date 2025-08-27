# modules/sql/variables.tf
# Updated for clarity, consistency, and optional tuning

variable "server_name" {
  type        = string
  description = "Name of the Azure SQL Server."
}

variable "db_name" {
  type        = string
  description = "Name of the SQL Database to create."
}

variable "location" {
  type        = string
  description = "Azure region for SQL resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for SQL resources."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common resource tags."
}

# ------------------------------------------------------------------
# Administration
# ------------------------------------------------------------------
variable "administrator_login" {
  type        = string
  description = "SQL administrator login name."
}

variable "administrator_login_password" {
  type        = string
  description = "SQL administrator password (should come from pipeline secret / Key Vault)."
  sensitive   = true
}

# ------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------
variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether to allow public network access (should be false in secure environments)."
}

# ------------------------------------------------------------------
# Server / DB Configuration
# ------------------------------------------------------------------
variable "sql_version" {
  type        = string
  default     = "12.0"
  description = "SQL Server version (e.g., '12.0')."
}

variable "db_sku_name" {
  type        = string
  default     = "S2"
  description = "SKU for the SQL Database (e.g., S0, S1, S2, GP_S_Gen5_2)."
}

variable "db_max_size_gb" {
  type        = number
  default     = 5
  description = "Max size of the SQL Database in GB."
}

variable "zone_redundant" {
  type        = bool
  default     = false
  description = "Whether the SQL Database should be zone redundant."
}

# ------------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------------
variable "enable_diagnostics" {
  type        = bool
  default     = true
  description = "Enable diagnostics to Log Analytics."
}

variable "la_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace resource ID (required if enable_diagnostics = true)."
}

# ------------------------------------------------------------------
# Private Endpoints
# ------------------------------------------------------------------
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a private endpoint for the SQL Server."
}

variable "pe_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint (required if enable_private_endpoints = true)."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs to associate with the private endpoint."
}
