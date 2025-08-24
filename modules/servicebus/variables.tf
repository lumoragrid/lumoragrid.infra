variable "name"        { 
	type = string 
	}
variable "location"    { 
	type = string 
	}
variable "rg_name"     { 
	type = string 
	}
variable "tags"  { 
	type = map(string) 
	default = {} 
	}
variable "sb_tier"     { 
	type = string 
	default = "Standard" 
} # Basic|Standard|Premium
variable "capacity"    { 
	type = number 
	default = 0 
}          # Premium only

variable "public_network_access_enabled" { type = bool default = true }
variable "ip_rules" { 
	type = list(string) 
	default = [] 
	}

variable "enable_diagnostics" { 
	type = bool 
	default = true 
}
variable "la_workspace_id"    { 
	type = string 
	default = null 
	}

# Entities
variable "queues"  { 
	type = list(string) 
	default = [] 
	}
variable "topics"  { 
	type = list(string) 
	default = [] 
}

# Private endpoints
variable "enable_private_endpoints" { 
	type = bool 
	default = false 
}
variable "pe_subnet_id"             { 
	type = string 
	default = null 
}
variable "private_dns_zone_ids"     { 
	type = list(string) 
	default = [] 
}
