# modules/servicebus/variables.tf
# Updated to align with module inputs used by envs/*/main.tf

variable "name" {
  type        = string
  description = "Service Bus namespace name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common resource tags."
}

# SKU / Capacity
variable "sb_tier" {
  type        = string
  default     = "Standard" # Allowed: Basic, Standard, Premium
  description = "Service Bus SKU."
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sb_tier)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Messaging units for Premium only; ignored for Basic/Standard."
  validation {
    # 0 is fine for non-Premium; Premium is enforced by a precondition in main.tf
    condition     = var.capacity == 0 || var.capacity >= 1
    error_message = "capacity must be 0 (when not Premium) or >= 1 (for Premium)."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is enabled on the namespace."
}

# Network ACLs (IP allowlist)
variable "ip_allowlist" {
  type        = list(string)
  default     = []
  description = "List of IP/CIDR strings allowed (e.g., [\"203.0.113.10/32\"])."
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
  description = "Log Analytics workspace resource ID (required when enable_diagnostics = true)."
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

# Queue behavior
variable "duplicate_detection_enabled" {
  type        = bool
  default     = false
  description = "Enable duplicate detection for queues."
}

variable "duplicate_detection_time_window" {
  type        = string
  default     = null
  description = "ISO 8601 duration (e.g., PT10M) for duplicate detection history window."
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

# Optional subnet rules (for VNet filtering)
variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Optional list of subnet IDs to allow via network rules."
}
