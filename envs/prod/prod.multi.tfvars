#############################################
# envs/prod/prod.multi.tfvars
# Minimal stub — values come from Azure DevOps
# Variable Groups (LumoraGrid.Common + LumoraGrid.Prod)
#############################################

# This file is intentionally minimal.
# All environment-specific variables (project, environment, subscription_id,
# tenant_id, regions map, diagnostics flags, Service Bus, Cosmos, SQL,
# Log Analytics SKU/retention, tags, ip_allowlist, etc.) are injected
# at pipeline runtime from Variable Groups / Key Vault.

# For local testing ONLY (do not commit secrets), you may temporarily
# uncomment and set non-secret values, e.g.:
#
# project     = "lumoragrid"
# environment = "prod"
# subscription_id = "f1854abf-877e-4e38-bf2c-b772ba2b6bdf"
# tenant_id       = "75569a98-0ea1-45b2-8b41-49b53465e6af"
# regions = {
#   aue = {
#     location      = "australiaeast"
#     address_space = "10.170.0.0/16"
#     subnets = { apps = "10.170.1.0/24", pe = "10.170.2.0/24" }
#   }
#   ase = {
#     location      = "australiasoutheast"
#     address_space = "10.171.0.0/16"
#     subnets = { apps = "10.171.1.0/24", pe = "10.171.2.0/24" }
#   }
#   uks = {
#     location      = "uksouth"
#     address_space = "10.172.0.0/16"
#     subnets = { apps = "10.172.1.0/24", pe = "10.172.2.0/24" }
#   }
#   weu = {
#     location      = "westeurope"
#     address_space = "10.173.0.0/16"
#     subnets = { apps = "10.173.1.0/24", pe = "10.173.2.0/24" }
#   }
# }
#
# All other values (enable_diagnostics, enable_private_endpoints,
# servicebus_sku, sb_capacity, cosmos_* settings, law_sku,
# log_analytics_retention_days, tags, ip_allowlist, sql_admin_*)
# should come from the Variable Groups.
