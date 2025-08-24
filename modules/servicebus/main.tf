# modules/servicebus/main.tf

# Namespace
resource "azurerm_servicebus_namespace" "ns" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.rg_name
  sku                           = var.sb_tier
  capacity                      = var.sb_tier == "Premium" ? var.capacity : null
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  network_rule_set {
    default_action = length(var.ip_rules) > 0 ? "Deny" : "Allow"
    ip_rules       = var.ip_rules
  }
}
# Network rules (version-agnostic)
resource "azurerm_servicebus_namespace_network_rule_set" "rules" {
  namespace_id = azurerm_servicebus_namespace.ns.id

  # If any IPs are supplied, deny by default and allow only those; else allow all
  default_action = length(var.ip_rules) > 0 ? "Deny" : "Allow"

  # Flat list of IP/CIDR strings, e.g. ["203.0.113.10/32"]
  ip_rules = var.ip_rules
}

# Queues (optional)
resource "azurerm_servicebus_queue" "q" {
  for_each     = toset(var.queues)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id
}

# Topics (optional)
resource "azurerm_servicebus_topic" "t" {
  for_each     = toset(var.topics)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id
}

# Diagnostics (use metric{} so it works across provider versions)
resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-sb"
  target_resource_id         = azurerm_servicebus_namespace.ns.id
  log_analytics_workspace_id = var.la_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Private Endpoint (namespace)
resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints ? 1 : 0
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

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints == false || var.pe_subnet_id != null
      error_message = "When enable_private_endpoints=true, pe_subnet_id must be provided."
    }
  }
}
