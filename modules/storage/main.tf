# modules/storage/main.tf
# Updated for consistency, security, and alignment with envs/*/main.tf

resource "azurerm_storage_account" "sa" {
  name                            = var.account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = var.account_kind
  account_tier                    = "Standard"
  account_replication_type        = var.replication_type
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.public_network_access_enabled
  tags                            = var.tags

  blob_properties {
    versioning_enabled = var.enable_versioning
    delete_retention_policy {
      days = var.enable_soft_delete ? 7 : 0
    }
    container_delete_retention_policy {
      days = var.enable_soft_delete ? 7 : 0
    }
  }
}

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-storage"
  target_resource_id         = azurerm_storage_account.sa.id
  log_analytics_workspace_id = var.la_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    precondition {
      condition     = var.enable_diagnostics == false || (var.la_workspace_id != null && length(var.la_workspace_id) > 0)
      error_message = "la_workspace_id must be provided when enable_diagnostics = true."
    }
  }
}

# Private Endpoint (blob subresource)
resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.account_name}-pe-blob"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "blob-connection"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "blob-dns"
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
