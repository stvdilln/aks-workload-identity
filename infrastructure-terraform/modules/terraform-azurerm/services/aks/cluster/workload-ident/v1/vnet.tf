resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.service_settings.name}"
  location            = var.context.location
  resource_group_name = var.context.resource_group_name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "kubesubnet"
    address_prefix = "10.0.1.0/24"
  }

  tags = var.tags
}

data "azurerm_subnet" "this" {
  name                 = "kubesubnet"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = var.context.resource_group_name
  depends_on           = [azurerm_virtual_network.this]
}
