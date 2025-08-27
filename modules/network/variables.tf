# modules/network/variables.tf
# Updated for consistency, security, and optional DDoS protection

variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "location" {
  type        = string
  description = "Azure region where the virtual network will be created."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to create the virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used the virtual network."
}

variable "subnets" {
  description = "Map of subnet_name => address_prefix (CIDR block)."
  type        = map(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the virtual network and related resources."
}

variable "enable_ddos" {
  type        = bool
  default     = false
  description = "Whether to deploy a DDoS protection plan and associate it with the virtual network."
}
