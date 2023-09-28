
module my_resource_group {
    source  = "../terraform-azurerm/services/resource-group/base/v1"
    context = var.context 
    name = var.name
    tags = var.tags
}  