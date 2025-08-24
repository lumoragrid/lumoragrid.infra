resource "azurerm_mssql_server" "server" {
  name                          = var.server_name
  resource_group_name           = var.rg_name
  location                      = var.location
  version                       = var.sql_version
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_mssql_database" "db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.server.id
  sku_name       = var.db_sku_name
  max_size_gb    = 5
  zone_redundant = false
  tags           = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics && var.la_workspace_id != null ? 1 : 0
  name                       = "diag-sql"
  target_resource_id         = azurerm_mssql_server.server.id
  log_analytics_workspace_id = var.la_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "sql-dns"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints == false || var.pe_subnet_id != null
      error_message = "When enable_private_endpoints=true, pe_subnet_id must be provided."
    }
  }
}
