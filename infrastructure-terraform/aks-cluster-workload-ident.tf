locals {
    default_resource_name_pod_ident = "${var.context.application_name}-pod-ident-${var.context.environment_name}-${random_string.random_suffix.result}-${module.coreinfra.context.location_suffix}"
    aks_service_offering_pod_ident  = var.aks_service_offerings[var.aks_cluster_size]
}
# this resource is mis-named, it should be aks_cluster_workload_ident
module "aks_cluster_pod_ident" {
  
  source  = "./modules/terraform-azurerm/services/aks/cluster/workload-ident/v1"
  #count = 1

  context = module.coreinfra.context
  tags    = local.all_tags

  service_settings = {
    name                = local.default_resource_name_pod_ident
    # AKS will not deploy to an existing resource group, it will create this one.
    resource_group_name = "${module.coreinfra.context.resource_group_name}-cluster-ident"
    node_count          = local.aks_service_offering_pod_ident.node_count
    node_size           = local.aks_service_offering_pod_ident.node_size
    node_min_count      = local.aks_service_offering_pod_ident.node_min_count
    node_max_count      = local.aks_service_offering_pod_ident.node_max_count
    # Allow only the current machine acecss to the Kubernetes API
    api_server_authorized_ip_ranges = ["${chomp(data.http.my_ip_address.response_body)}/32" ]
    kubernetes_version  = "1.25.11" 
  }
  # The Observability settings that help create keyvault
  # in a best practices manner
  observability_settings    = module.coreinfra.observability_settings
}
