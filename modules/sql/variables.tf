variable "server_name"  { type = string }
variable "db_name"      { type = string }
variable "location"     { type = string }
variable "rg_name"      { type = string }
variable "tags"         { 
	type = map(string) 
	default = {} 
	}

# Admin (use AAD later; for POC allow SQL login via pipeline secrets)
variable "administrator_login"           { type = string }
variable "administrator_login_password"  { type = string }

variable "public_network_access_enabled" { 
	type = bool 
	default = true 
	}
variable "sql_version" { 
	type = string 
	default = "12.0" 
	}

# SKU (example: 'S0', 'S1', 'S2', or 'Basic' etc., or GP_S_Gen5_1 for vCore)
variable "db_sku_name" { 
	type = string 
	default = "S2" 
	}

variable "enable_diagnostics" { 
	type = bool 
	default = true 
	}
variable "la_workspace_id"    { 
	type = string 
	default = null 
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
