# Namespace
resource "azurerm_servicebus_namespace" "ns" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.rg_name
  sku                           = var.sb_tier                     # "Standard" or "Premium"
  capacity                      = var.sb_tier == "Premium" ? var.capacity : null
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  lifecycle {
    precondition {
      condition     = contains(["Basic", "Standard", "Premium"], var.sb_tier)
      error_message = "sb_tier must be one of: Basic, Standard, Premium."
    }
    precondition {
      condition     = var.sb_tier != "Premium" || contains([1, 2, 4], var.capacity)
      error_message = "When sb_tier is \"Premium\", capacity must be 1, 2, or 4."
    }
  }
}

# Network rules (separate resource – replaces inline network_rule_set)
resource "azurerm_servicebus_namespace_network_rule_set" "rules" {
  resource_group_name = var.rg_name
  namespace_name      = azurerm_servicebus_namespace.ns.name

  # If any IPs provided → default deny + explicit allows; else allow all
  default_action = length(var.ip_rules) > 0 ? "Deny" : "Allow"

  dynamic "ip_rule" {
    for_each = var.ip_rules
    content {
      ip_mask = ip_rule.value
      action  = "Allow"
    }
  }

  # Add virtual_network_rule blocks later if you lock to VNets.
}

# Queues (optional)
resource "azurerm_servicebus_queue" "q" {
  for_each            = toset(var.queues)
  name                = each.value
  namespace_id        = azurerm_servicebus_namespace.ns.id
  enable_partitioning = true
}

# Topics (optional)
resource "azurerm_servicebus_topic" "t" {
  for_each     = toset(var.topics)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id
}

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics && var.la_workspace_id != null ? 1 : 0
  name                       = "diag-sb"
  target_resource_id         = azurerm_servicebus_namespace.ns.id
  log_analytics_workspace_id = var.la_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Private Endpoint (namespace)
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
