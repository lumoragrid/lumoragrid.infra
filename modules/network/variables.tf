variable "name"          { 
	type = string 
	}
variable "location"      { 
	type = string 
	}
variable "rg_name"       { 
	type = string 
	}
variable "address_space" { 
	type = list(string) 
	}
variable "subnets" {
  description = "Map of subnet_name => address_prefix"
  type        = map(string)
}
variable "tags" { 
	type = map(string) 
	default = {} 
}
