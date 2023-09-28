locals {
  default_tags = {
    created-by  = "terraform"
    environment = var.context.environment_name
    app = var.context.application_name
    env = var.context.environment_name
  }
  all_tags = merge(local.default_tags, var.tags == {} ? null : var.tags)
}



resource "azurerm_resource_group" "rg" {

  name      = var.name
  location  = var.context.location

  tags = local.all_tags

}