resource "azurerm_servicebus_namespace" "ns" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.sb_tier
  capacity            = var.sb_tier == "Premium" ? var.capacity : null
  public_network_access_enabled = var.public_network_access_enabled
  tags                = var.tags

  dynamic "network_rule_set" {
    for_each = length(var.ip_rules) > 0 ? [1] : []
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = var.ip_rules
        content {
          action  = "Allow"
          ip_mask = ip_rule.value
        }
      }
    }
  }
}

resource "azurerm_servicebus_queue" "q" {
  for_each            = toset(var.queues)
  name                = each.value
  namespace_id        = azurerm_servicebus_namespace.ns.id
  enable_partitioning = true
}

resource "azurerm_servicebus_topic" "t" {
  for_each     = toset(var.topics)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics && var.la_workspace_id != null ? 1 : 0
  name                       = "diag-sb"
  target_resource_id         = azurerm_servicebus_namespace.ns.id
  log_analytics_workspace_id = var.la_workspace_id

  metric { 
    category = "AllMetrics" 
    enabled = true 
    }
}

resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints && var.pe_subnet_id != null ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "sb-connection"
    private_connection_resource_id = azurerm_servicebus_namespace.ns.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "sb-dns"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}
