variable "name" {
  type        = string
  description = "Service Bus namespace name."
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
  description = "Common resource tags."
}

variable "sb_tier" {
  type        = string
  default     = "Standard" # Allowed: Basic, Standard, Premium
  description = "Service Bus SKU."
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sb_tier)
    error_message = "sb_tier must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Messaging units for Premium only (ignored for Basic/Standard)."
  validation {
    condition     = var.sb_tier != "Premium" || var.capacity >= 1
    error_message = "capacity must be >= 1 when sb_tier is Premium."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is enabled on the namespace."
}

# Network rules (IP + optional subnets)
variable "ip_rules" {
  type        = list(string)
  default     = []
  description = "List of IP/CIDR strings allowed (e.g., [\"203.0.113.10/32\"])."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Optional list of subnet IDs to allow via network rules."
}

variable "trusted_services_enabled" {
  type        = bool
  default     = false
  description = "Allow trusted Microsoft services to bypass network rules."
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
  validation {
    condition     = var.enable_diagnostics == false || try(length(var.la_workspace_id) > 0, false)
    error_message = "la_workspace_id must be set when enable_diagnostics is true."
  }
}

# Entities
variable "queues" {
  type        = list(string)
  default     = []
  description = "Queue names to create."
}

variable "topics" {
  type        = list(string)
  default     = []
  description = "Topic names to create."
}

# Private endpoints
variable "enable_private_endpoints" {
  type        = bool
  default     = false
  description = "Create a private endpoint for the namespace."
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
