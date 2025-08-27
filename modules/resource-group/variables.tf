# modules/resource-group/variables.tf

variable "name" {
  type        = string
  description = "Name of the Resource Group."
}

variable "location" {
  type        = string
  description = "Azure region where the Resource Group will be created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the Resource Group."
}
