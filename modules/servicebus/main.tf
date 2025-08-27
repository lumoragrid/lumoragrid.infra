# modules/servicebus/main.tf
# Updated to align with env main.tf inputs:
# - resource_group_name
# - sku, capacity
# - ip_allowlist
# - enable_private_endpoints
# - enable_diagnostics, la_workspace_id
# - duplicate_detection_enabled (applies to queues)

# Namespace
resource "azurerm_servicebus_namespace" "ns" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku      = var.sb_tier
  capacity = var.sb_tier == "Premium" ? var.capacity : null

  # Keep PNA enabled unless you explicitly disable it in variables (optional var with default = true)
  public_network_access_enabled = try(var.public_network_access_enabled, true)
  minimum_tls_version           = "1.2"

  tags = var.tags

  # Network ACLs (v4)
  network_rule_set {
    # If any rules are present, default must be Deny
    default_action           = length(var.ip_allowlist) > 0 ? "Deny" : "Allow"
    ip_rules                 = var.ip_allowlist
    trusted_services_allowed = try(var.trusted_services_enabled, false)

    dynamic "network_rules" {
      for_each = try(var.subnet_ids, [])
      content {
        subnet_id                            = network_rules.value
        ignore_missing_vnet_service_endpoint = false
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.sb_tier != "Premium" || var.capacity >= 1
      error_message = "When sku is Premium, capacity must be >= 1."
    }
  }
}

# Queues (optional)
resource "azurerm_servicebus_queue" "q" {
  for_each     = toset(var.queues)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id

  # Apply duplicate detection if requested (queue-level feature)
  requires_duplicate_detection         = try(var.duplicate_detection_enabled, false)
  duplicate_detection_history_time_window = try(var.duplicate_detection_time_window, null)
}

# Topics (optional)
resource "azurerm_servicebus_topic" "t" {
  for_each     = toset(var.topics)
  name         = each.value
  namespace_id = azurerm_servicebus_namespace.ns.id
}

# Diagnostics
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

  lifecycle {
    precondition {
      condition     = var.la_workspace_id != null && length(var.la_workspace_id) > 0
      error_message = "la_workspace_id must be provided when enable_diagnostics = true."
    }
  }
}

# Private Endpoint (namespace)
resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "sb-connection"
    private_connection_resource_id = azurerm_servicebus_namespace.ns.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(try(var.private_dns_zone_ids, [])) > 0 ? [1] : []
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
