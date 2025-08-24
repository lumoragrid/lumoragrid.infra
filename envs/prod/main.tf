terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm",
      version = ">= 3.107.0"
    }
    random = {
      source  = "hashicorp/random",
      version = ">= 3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Uncomment and configure when ready to move to remote state
#terraform {
#  backend "azurerm" {
#    resource_group_name  = "STATE_RG"
#    storage_account_name = "statestorageacct"
#    container_name       = "tfstate"
#    key                  = "lumoragrid-${var.env}.tfstate"
#  }
#}

variable "env" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "tenant_id" { type = string }
variable "ip_allowlist" {
  type    = list(string)
  default = []
}

variable "enable_private_endpoints" {
  type    = bool
  default = false
}
variable "enable_diagnostics" {
  type    = bool
  default = true
}

variable "sb_tier" {
  type    = string
  default = "Standard"
}
variable "sb_capacity" {
  type    = number
  default = 0
}

variable "cosmos_serverless" {
  type    = bool
  default = true
}
variable "cosmos_enable_free_tier" {
  type    = bool
  default = true
}

variable "sql_admin_login" {
  type    = string
  default = "sqladminuser"
}
variable "sql_admin_password" { type = string }

# Names and random suffix for global uniqueness (storage/servicebus/cosmos)
resource "random_id" "suffix" {
  byte_length = 3
  keepers     = { env = var.env }
}

locals {
  name_prefix = "${var.prefix}-${var.env}"
  rg_name     = "rg-${var.prefix}-${var.env}-core"
  vnet_name   = "vnet-${var.prefix}-${var.env}"
  tags = {
    app   = "lumoragrid"
    env   = var.env
    owner = "platform"
  }
}

module "rg" {
  source   = "../../modules/resource-group"
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

module "monitor" {
  source         = "../../modules/monitor"
  name_prefix    = local.name_prefix
  location       = var.location
  rg_name        = module.rg.name
  retention_days = var.env == "prod" ? 30 : (var.env == "uat" ? 30 : 14)
  tags           = local.tags
}

module "network" {
  source        = "../../modules/network"
  name          = local.vnet_name
  location      = var.location
  rg_name       = module.rg.name
  address_space = ["10.${var.env == "prod" ? 3 : var.env == "uat" ? 2 : var.env == "test" ? 1 : 0}.0.0/16"]
  subnets = {
    "apps" = "10.${var.env == "prod" ? 3 : var.env == "uat" ? 2 : var.env == "test" ? 1 : 0}.1.0/24"
    "pe"   = "10.${var.env == "prod" ? 3 : var.env == "uat" ? 2 : var.env == "test" ? 1 : 0}.2.0/24"
  }
  tags = local.tags
}

# Storage (blob)
module "storage" {
  source                        = "../../modules/storage"
  account_name                  = lower(replace("${var.prefix}${var.env}${random_id.suffix.hex}", "-", ""))
  location                      = var.location
  rg_name                       = module.rg.name
  enable_diagnostics            = var.enable_diagnostics
  la_workspace_id               = module.monitor.log_analytics_workspace_id
  public_network_access_enabled = true
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network.subnet_ids["pe"]
  tags                          = local.tags
}

# Key Vault
module "keyvault" {
  source                        = "../../modules/keyvault"
  name                          = "kv-${var.prefix}-${var.env}-${random_id.suffix.hex}"
  location                      = var.location
  rg_name                       = module.rg.name
  tenant_id                     = var.tenant_id
  public_network_access_enabled = true
  enable_purge_protection       = true
  enable_diagnostics            = var.enable_diagnostics
  la_workspace_id               = module.monitor.log_analytics_workspace_id
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network.subnet_ids["pe"]
  tags                          = local.tags
}

# Service Bus
module "servicebus" {
  source                        = "../../modules/servicebus"
  name                          = "sb-${var.prefix}-${var.env}-${random_id.suffix.hex}"
  location                      = var.location
  rg_name                       = module.rg.name
  sb_tier                       = var.sb_tier
  capacity                      = var.sb_capacity
  public_network_access_enabled = true
  ip_rules                      = var.ip_allowlist
  enable_diagnostics            = var.enable_diagnostics
  la_workspace_id               = module.monitor.log_analytics_workspace_id
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network.subnet_ids["pe"]

  # Seed entities (adjust to your needs)
  queues = [
    "ai-tailor-requests",
    "application-tasks",
    "submission-results"
  ]
  topics = [
    "jobs-discovered",
    "jobs-deduped"
  ]
  tags = local.tags
}

# Cosmos DB (Core SQL API)
module "cosmos" {
  source                        = "../../modules/cosmos"
  name                          = "cos-${var.prefix}-${var.env}-${random_id.suffix.hex}"
  location                      = var.location
  rg_name                       = module.rg.name
  cosmos_serverless             = var.cosmos_serverless
  enable_free_tier              = var.cosmos_enable_free_tier
  public_network_access_enabled = true
  enable_diagnostics            = var.enable_diagnostics
  la_workspace_id               = module.monitor.log_analytics_workspace_id
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network.subnet_ids["pe"]
  tags                          = local.tags
}

# SQL (POC: SQL login; later switch to AAD-only and Private Link)
module "sql" {
  source                       = "../../modules/sql"
  server_name                  = "sql-${var.prefix}-${var.env}-${random_id.suffix.hex}"
  db_name                      = "sqldb_${var.prefix}_${var.env}"
  location                     = var.location
  rg_name                      = module.rg.name
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  public_network_access_enabled = true
  db_sku_name                   = var.env == "dev" ? "S0" : (var.env == "test" ? "S1" : "S2")
  enable_diagnostics            = var.enable_diagnostics
  la_workspace_id               = module.monitor.log_analytics_workspace_id
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network.subnet_ids["pe"]
  tags                          = local.tags
}
