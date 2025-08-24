variable "name"        { type = string }
variable "location"    { type = string }
variable "rg_name"     { type = string }
variable "tags"        { type = map(string) default = {} }

variable "cosmos_serverless" { type = bool default = true }
variable "enable_free_tier"  { type = bool default = true }

variable "public_network_access_enabled" { type = bool default = true }
variable "enable_diagnostics"            { type = bool default = true }
variable "la_workspace_id"               { type = string default = null }

# Private endpoints
variable "enable_private_endpoints" { type = bool default = false }
variable "pe_subnet_id"             { type = string default = null }
variable "private_dns_zone_ids"     { type = list(string) default = [] }
