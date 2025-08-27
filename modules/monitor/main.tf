# modules/monitor/main.tf
# Updated for consistency with envs/*/main.tf (LAW + App Insights)

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = var.law_sku
  retention_in_days = var.law_sku == "Free" ? 7 : var.retention_days

  tags = var.tags
}

resource "azurerm_application_insights" "appins" {
  name                = "${var.name_prefix}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id

  tags = var.tags
}
