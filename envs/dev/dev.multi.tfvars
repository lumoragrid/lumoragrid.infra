#############################################
# envs/dev/dev.multi.tfvars
# Minimal stub — all values come from Azure DevOps
# Variable Groups (LumoraGrid.Common + LumoraGrid.Dev)
#############################################

# This file is intentionally minimal.
# Environment-specific variables (project, environment, subscription_id,
# tenant_id, regions map, diagnostics flags, Service Bus, Cosmos, SQL,
# Log Analytics SKU/retention, tags, ip_allowlist, etc.) are injected
# at pipeline runtime from Variable Groups / Key Vault.

# For local testing ONLY (do not commit secrets), you may temporarily
# uncomment and set non-secret values, e.g.:
#
# project     = "lumoragrid"
# environment = "dev"
# subscription_id = "f1854abf-877e-4e38-bf2c-b772ba2b6bdf"
# tenant_id       = "75569a98-0ea1-45b2-8b41-49b53465e6af"
# regions = {
#   au-east = {
#     location      = "australiaeast"
#     address_space = "10.140.0.0/16"
#     subnets = { apps = "10.140.1.0/24", pe = "10.140.2.0/24" }
#   }
#   au-se = {
#     location      = "australiasoutheast"
#     address_space = "10.141.0.0/16"
#     subnets = { apps = "10.141.1.0/24", pe = "10.141.2.0/24" }
#   }
# }
#
# All other values (enable_diagnostics, enable_private_endpoints,
# servicebus_sku, sb_capacity, cosmos_* settings, law_sku,
# log_analytics_retention_days, tags, ip_allowlist, sql_admin_*)
# should come from the Variable Groups.
