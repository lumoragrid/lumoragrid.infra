terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

#############################################
# Locals: naming, regions, and common tags  #
#############################################

locals {
  # From variables.tf / pipeline
  project          = var.project
  environment      = var.environment
  regions_map      = var.regions                                   # map-of-objects
  region_locations = [for _, v in var.regions : v.location]        # list of location strings (order preserved)

  # ---- Region filtering (single-region runs) ----
  selected_region_locations = var.target_region != "" ?
    [for loc in local.region_locations : loc if loc == var.target_region] :
    local.region_locations

  # By-location lookup (filtered to selection)
  regions_by_location = {
    for _, v in var.regions :
    v.location => v
    if var.target_region == "" || v.location == var.target_region
  }

  # Primary region = first selected location (deterministic)
  primary_region = length(local.selected_region_locations) > 0 ? local.selected_region_locations[0] : "australiaeast"

  # Short codes for Azure regions used in resource names.
  region_short = {
    "australiaeast"       = "aue"
    "australiasoutheast"  = "ase"
    "australiacentral"    = "auc"
    "eastasia"            = "eas"
    "southeastasia"       = "sea"
    "eastus"              = "eus"
    "eastus2"             = "eu2"
    "centralus"           = "cus"
    "westus"              = "wus"
    "westus2"             = "wu2"
    "westus3"             = "wu3"
    "uksouth"             = "uks"
    "ukwest"              = "ukw"
    "northeurope"         = "neu"
    "westeurope"          = "weu"
    "japaneast"           = "jpe"
    "japanwest"           = "jpw"
    "koreacentral"        = "kor"
    "centralindia"        = "cin"
    "southindia"          = "sin"
    "westindia"           = "win"
  }

  # Safe suffix for global names (e.g., Cosmos) – deterministic and hyphen-free.
  global_suffix = lower(replace("${local.project}${local.environment}", "-", ""))

  # Base prefix for most regional resources.
  prefix = "${local.project}-${local.environment}"

  # Merge standard tags with user-supplied tags.
  tags = merge(
    {
      Project     = local.project
      Environment = local.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  #############################################
  # Per-region deterministic names (filtered) #
  #############################################

  resource_group_names = {
    for loc in local.selected_region_locations :
    loc => "${local.prefix}-rg-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  monitor_name_prefixes = {
    for loc in local.selected_region_locations :
    loc => "${local.prefix}-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  servicebus_namespace_names = {
    for loc in local.selected_region_locations :
    loc => "${local.prefix}-sb-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  vnet_names = {
    for loc in local.selected_region_locations :
    loc => "${local.prefix}-vnet-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  # Storage account name: 3–24 lower alnum
  storage_account_names = {
    for loc in local.selected_region_locations :
    loc => substr(lower(replace("${local.project}${local.environment}${lookup(local.region_short, loc, substr(loc, 0, 3))}st", "-", "")), 0, 24)
  }

  # Key Vault name: 3–24 lower alnum
  key_vault_names = {
    for loc in local.selected_region_locations :
    loc => substr(lower(replace("${local.project}${local.environment}${lookup(local.region_short, loc, substr(loc, 0, 3))}kv", "-", "")), 0, 24)
  }

  # SQL server and DB names (server: 1–63, db: up to 128)
  sql_server_name = "${local.prefix}-sql-${lookup(local.region_short, local.primary_region, substr(local.primary_region, 0, 3))}"
  sql_db_name     = "${local.project}_${local.environment}"

  # Cosmos account name must be globally unique & lowercase, 3–44 chars, no hyphens.
  cosmos_account_name = substr(lower(replace("${local.global_suffix}cosmos", "-", "")), 0, 44)
}

#############################################
# Per-Region Resource Groups                 #
#############################################

module "resource_groups" {
  source = "../../modules/resource-group"

  for_each = toset(local.selected_region_locations)

  name     = local.resource_group_names[each.key]
  location = each.key
  tags     = local.tags
}

#############################################
# Per-Region Network (VNet + subnets)       #
#############################################

module "network" {
  source = "../../modules/network"

  for_each = toset(local.selected_region_locations)

  name     = local.vnet_names[each.key]
  location = each.key
  rg_name  = module.resource_groups[each.key].name

  # module expects list(string) for address_space and map(string) for subnets
  address_space = [local.regions_by_location[each.key].address_space]
  subnets       = local.regions_by_location[each.key].subnets

  tags = local.tags
}

#############################################
# Per-Region Monitoring (LAW + App Insights)#
#############################################

module "monitor" {
  source = "../../modules/monitor"

  for_each = toset(local.selected_region_locations)

  name_prefix         = local.monitor_name_prefixes[each.key]
  location            = each.key
  resource_group_name = module.resource_groups[each.key].name

  law_sku        = var.law_sku
  retention_days = var.log_analytics_retention_days

  tags = local.tags
}

#############################################
# Per-Region Storage Accounts (toggle)      #
#############################################

module "storage" {
  source = "../../modules/storage"

  for_each = {
    for loc in local.selected_region_locations :
    loc => loc
    if try(local.regions_by_location[loc].enable_storage, true)
  }

  account_name        = local.storage_account_names[each.key]
  location            = each.key
  rg_name             = module.resource_groups[each.key].name

  account_kind        = var.storage.account_kind
  replication_type    = var.storage.replication_type

  enable_diagnostics  = var.enable_diagnostics
  la_workspace_id     = module.monitor[each.key].log_analytics_workspace_id

  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network[each.key].subnet_ids["pe"]
  public_network_access_enabled = var.enable_private_endpoints ? false : true
  private_dns_zone_ids          = []

  tags = local.tags
}

#############################################
# Per-Region Service Bus Namespaces         #
#############################################

module "servicebus" {
  source  = "../../modules/servicebus"

  for_each = {
    for loc in local.selected_region_locations :
    loc => loc
    if try(local.regions_by_location[loc].enable_servicebus, true)
  }

  name     = local.servicebus_namespace_names[each.key]
  location = each.key
  rg_name  = module.resource_groups[each.key].name

  # Sizing & SKU
  sb_tier  = var.servicebus_sku
  capacity = var.sb_capacity

  # Network & security
  public_network_access_enabled = var.enable_private_endpoints ? false : true
  ip_allowlist                  = var.ip_allowlist
  trusted_services_enabled      = true

  # Diagnostics
  enable_diagnostics = var.enable_diagnostics
  la_workspace_id    = module.monitor[each.key].log_analytics_workspace_id

  # Private Endpoint specifics
  enable_private_endpoints = var.enable_private_endpoints
  pe_subnet_id             = module.network[each.key].subnet_ids["pe"]
  private_dns_zone_ids     = []

  tags = local.tags
}

#############################################
# Key Vault (toggle; per-region)            #
#############################################

module "keyvault" {
  source = "../../modules/keyvault"

  for_each = {
    for loc in local.selected_region_locations :
    loc => loc
    if try(local.regions_by_location[loc].enable_keyvault, true)
  }

  name                = local.key_vault_names[each.key]
  location            = each.key
  rg_name             = module.resource_groups[each.key].name
  tenant_id           = var.tenant_id
  tags                = local.tags

  public_network_access_enabled = var.enable_private_endpoints ? false : true
  enable_purge_protection       = true

  enable_private_endpoints = var.enable_private_endpoints
  pe_subnet_id             = module.network[each.key].subnet_ids["pe"]
  private_dns_zone_ids     = []

  enable_diagnostics = var.enable_diagnostics
  la_workspace_id    = module.monitor[each.key].log_analytics_workspace_id
}

#############################################
# Cosmos DB (primary region account)        #
#############################################

module "cosmos" {
  source = "../../modules/cosmos"

  # Account & placement (primary only here)
  name     = local.cosmos_account_name
  location = local.primary_region
  rg_name  = module.resource_groups[local.primary_region].name

  # Account mode/cost controls
  cosmos_serverless = var.cosmos_serverless
  enable_free_tier  = var.cosmos_enable_free_tier

  # (Optional) Multi-region:
  # enable_multi_region       = true
  # read_regions              = [for loc in local.selected_region_locations : loc if loc != local.primary_region]
  # consistency_level         = var.cosmos_consistency_level
  automatic_failover_enabled    = true

  # Networking
  public_network_access_enabled = var.enable_private_endpoints ? false : true
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network[local.primary_region].subnet_ids["pe"]
  private_dns_zone_ids          = []

  # Diagnostics
  enable_diagnostics = var.enable_diagnostics
  la_workspace_id    = module.monitor[local.primary_region].log_analytics_workspace_id

  tags = local.tags
}

#############################################
# SQL (primary region)                      #
#############################################

module "sql" {
  source = "../../modules/sql"

  server_name = lower(replace(local.sql_server_name, "_", "-"))
  db_name     = local.sql_db_name
  location    = local.primary_region
  rg_name     = module.resource_groups[local.primary_region].name

  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  sql_version    = "12.0"
  db_sku_name    = "S2"
  db_max_size_gb = 5
  zone_redundant = false

  # Networking & PE
  public_network_access_enabled = var.enable_private_endpoints ? false : true
  enable_private_endpoints      = var.enable_private_endpoints
  pe_subnet_id                  = module.network[local.primary_region].subnet_ids["pe"]
  private_dns_zone_ids          = []

  # Diagnostics
  enable_diagnostics = var.enable_diagnostics
  la_workspace_id    = module.monitor[local.primary_region].log_analytics_workspace_id

  tags = local.tags
}

#############################################
# Identity (optional RBAC assignments)      #
#############################################

module "identity" {
  source = "../../modules/identity"

  role_assignments = []
}

#############################################
# Useful Outputs                             #
#############################################

output "resource_group_names" {
  description = "Per-region resource group names."
  value       = local.resource_group_names
}

output "vnet_ids" {
  description = "Per-region VNet IDs."
  value       = { for r, m in module.network : r => m.vnet_id }
}

output "log_analytics_workspace_ids" {
  description = "Per-region Log Analytics workspace IDs."
  value       = { for r, m in module.monitor : r => m.log_analytics_workspace_id }
}

output "servicebus_namespace_names" {
  description = "Per-region Service Bus namespace names."
  value       = local.servicebus_namespace_names
}

output "storage_account_names" {
  description = "Per-region Storage Account names (only for enabled regions)."
  value       = { for r, m in module.storage : r => m.name }
}

output "key_vault_names" {
  description = "Per-region Key Vault names (only for enabled regions)."
  value       = { for r, m in module.keyvault : r => m.name }
}

output "cosmos_account_name" {
  description = "Cosmos DB account name (global)."
  value       = module.cosmos.name
}
