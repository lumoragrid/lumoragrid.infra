# modules/monitor/variables.tf
# Updated for clarity and consistency across modules

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming the Log Analytics workspace and Application Insights."
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to create monitoring resources."
}

variable "retention_days" {
  type        = number
  default     = 30
  description = "Retention period (in days) for Log Analytics data. Ignored if law_sku == Free."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common resource tags applied to all monitoring resources."
}

variable "law_sku" {
  type        = string
  default     = "PerGB2018"
  description = "Log Analytics SKU (PerGB2018 | Free)."
}
