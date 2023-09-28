locals {
    default_tags = {
      app = var.context.application_name
      env = var.context.environment_name
    }

    final_tags = merge (local.default_tags, var.tags ) 
}
resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.service_settings.name
  location            = var.context.location
  resource_group_name = var.context.resource_group_name
  dns_prefix          = var.service_settings.name
  api_server_access_profile {
    authorized_ip_ranges = var.service_settings.api_server_authorized_ip_ranges
  }

  node_resource_group = var.service_settings.resource_group_name
  kubernetes_version  = var.service_settings.kubernetes_version

  default_node_pool {
    name       = "default"
    #node_count = var.service_settings.node_count
    enable_auto_scaling = true
    min_count   = var.service_settings.node_min_count
    max_count   = var.service_settings.node_max_count
    vm_size     = var.service_settings.node_size
    #vnet_subnet_id = data.azurerm_subnet.this
  }

  identity {
    type = "SystemAssigned"
  }
  # Enable OIDC provider 
  # *** WORKLOAD IDENTITY  ****
  #
  oidc_issuer_enabled = true 

  oms_agent {
      log_analytics_workspace_id      = var.observability_settings.workspace_id 
      msi_auth_for_monitoring_enabled = true 
  }
  network_profile {
    network_plugin= "kubenet"
    load_balancer_sku = "standard"
  }

  tags = local.final_tags

}

# USE THIS ONE!
#https://2bcloud.io/using-aks-with-workload-identities-in-terraform/

