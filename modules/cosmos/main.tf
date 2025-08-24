resource "azurerm_cosmosdb_account" "acct" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  enable_automatic_failover = false
  enable_free_tier          = var.enable_free_tier
  public_network_access_enabled = var.public_network_access_enabled
  tags                = var.tags

  consistency_policy {
    consistency_level = "Session"
  }

  dynamic "capabilities" {
    for_each = var.cosmos_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics && var.la_workspace_id != null ? 1 : 0
  name                       = "diag-cosmos"
  target_resource_id         = azurerm_cosmosdb_account.acct.id
  log_analytics_workspace_id = var.la_workspace_id

  metric { 
    category = "AllMetrics" 
    enabled = true 
    }
}

# Private Endpoint (SQL API)
resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints && var.pe_subnet_id != null ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "cosmos-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.acct.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "cosmos-dns"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}
