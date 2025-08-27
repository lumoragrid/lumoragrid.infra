# modules/network/main.tf
# Updated for consistency, security, and private endpoint readiness

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]

  # By default allow private endpoints
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = false
}

# Optional: DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.enable_ddos ? 1 : 0
  name                = "${var.name}-ddos"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Associate DDoS plan with VNet if enabled
resource "azurerm_virtual_network_ddos_protection_plan_association" "ddos_assoc" {
  count                     = var.enable_ddos ? 1 : 0
  virtual_network_id        = azurerm_virtual_network.vnet.id
  ddos_protection_plan_id   = azurerm_network_ddos_protection_plan.ddos[0].id
}
