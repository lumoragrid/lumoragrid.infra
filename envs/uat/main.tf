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
  project          = var.project
  environment      = var.environment
  regions_map      = var.regions
  region_locations = [for _, v in var.regions : v.location]
  primary_region   = length(keys(var.regions)) > 0 ? var.regions[keys(var.regions)[0]].location : "australiaeast"

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

  global_suffix = lower(replace("${local.project}${local.environment}", "-", ""))
  prefix        = "${local.project}-${local.environment}"

  tags = merge(
    {
      Project     = local.project
      Environment = local.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  resource_group_names = {
    for loc in local.region_locations :
    loc => "${local.prefix}-rg-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  log_analytics_names = {
    for loc in local.region_locations :
    loc => "${local.prefix}-law-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  servicebus_namespace_names = {
    for loc in local.region_locations :
    loc => "${local.prefix}-sb-${lookup(local.region_short, loc, substr(loc, 0, 3))}"
  }

  cosmos_account_name = substr(lower(replace("${local.global_suffix}cosmos", "-", "")), 0, 44)
}

#############################################
# Per-Region Resource Groups                 #
#############################################

module "resource_groups" {
  source = "../../modules/resource-group"

  for_each = toset(local.region_locations)

  name     = local.resource_group_names[each.key]
  location = each.key
  tags     = local.tags
}

#############################################
# Per-Region Log Analytics Workspaces        #
#############################################

module "log_analytics" {
  source = "../../modules/monitor"

  for_each = toset(local.region_locations)

  name                = local.log_analytics_names[each.key]
  location            = each.key
  resource_group_name = local.resource_group_names[each.key]

  sku               = var.law_sku
  retention_in_days = var.log_analytics_retention_days

  tags = local.tags
}

#############################################
# Per-Region Service Bus Namespaces          #
#############################################

module "servicebus" {
  source = "../../modules/servicebus"

  for_each = toset(local.region_locations)

  name                = local.servicebus_namespace_names[each.key]
  location            = each.key
  resource_group_name = local.resource_group_names[each.key]

  sku      = var.servicebus_sku
  capacity = var.sb_capacity

  enable_private_endpoints = var.enable_private_endpoints
  ip_allowlist             = var.ip_allowlist

  enable_diagnostics = var.enable_diagnostics
  la_workspace_id    = module.monitor[each.key].id

  duplicate_detection_enabled = true

  tags = local.tags
}

#############################################
# Cosmos DB (primary in first region;        #
# replicas in remaining regions)             #
#############################################

module "cosmos" {
  source = "../../modules/cosmos"

  name                = local.cosmos_account_name
  location            = local.primary_region
  resource_group_name = local.resource_group_names[local.primary_region]

  enable_multi_region       = true
  read_regions              = [for loc in local.region_locations : loc if loc != local.primary_region]
  enable_automatic_failover = true

  consistency_level = var.cosmos_consistency_level
  serverless        = var.cosmos_serverless
  free_tier         = var.cosmos_enable_free_tier

  enable_private_endpoints = var.enable_private_endpoints
  enable_diagnostics       = var.enable_diagnostics
  la_workspace_id          = module.monitor[local.primary_region].id

  tags = local.tags
}

#############################################
# Useful Outputs                             #
#############################################

output "resource_group_names" {
  description = "Per-region resource group names."
  value       = local.resource_group_names
}

output "log_analytics_workspace_ids" {
  description = "Per-region Log Analytics workspace IDs."
  value       = { for r, m in module.log_analytics : r => m.id }
}

output "servicebus_namespace_names" {
  description = "Per-region Service Bus namespace names."
  value       = local.servicebus_namespace_names
}

output "cosmos_account_name" {
  description = "Cosmos DB account name (global)."
  value       = module.cosmos.name
}
