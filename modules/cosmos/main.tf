# modules/cosmos/main.tf
# Updated to align with env main.tf inputs:
# - resource_group_name
# - consistency_level, serverless, free_tier
# - enable_multi_region, read_regions, automatic_failover
# - diagnostics & private endpoints

resource "azurerm_cosmosdb_account" "acct" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  offer_type = "Standard"
  kind       = "GlobalDocumentDB"

  automatic_failover_enabled    = var.enable_automatic_failover
  free_tier_enabled             = var.free_tier
  public_network_access_enabled = try(var.public_network_access_enabled, true)

  # Primary region
  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }

  # Read replicas (if enabled)
  dynamic "geo_location" {
    for_each = var.enable_multi_region ? toset(var.read_regions) : []
    content {
      location          = geo_location.value
      failover_priority = 1
      zone_redundant    = false
    }
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  dynamic "capabilities" {
    for_each = var.cosmos_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  tags = var.tags
}

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-cosmos"
  target_resource_id         = azurerm_cosmosdb_account.acct.id
  log_analytics_workspace_id = var.la_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    precondition {
      condition     = var.la_workspace_id != null && length(var.la_workspace_id) > 0
      error_message = "la_workspace_id must be provided when enable_diagnostics = true."
    }
  }
}

# Private Endpoint (SQL API)
resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "cosmos-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.acct.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(try(var.private_dns_zone_ids, [])) > 0 ? [1] : []
    content {
      name                 = "cosmos-dns"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints == false || var.pe_subnet_id != null
      error_message = "When enable_private_endpoints = true, pe_subnet_id must be provided."
    }
  }
}
