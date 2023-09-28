resource "azurerm_user_assigned_identity" "app1" {
    name = "demo-app1-identity"
    location = module.coreinfra.context.location
    resource_group_name = module.coreinfra.context.resource_group_name
}
output "aks_workload_app1_client_id" {
    value = azurerm_user_assigned_identity.app1.client_id
}
output "aks_workload_app1_user_name" {
    value = azurerm_user_assigned_identity.app1.name
}

resource "azurerm_federated_identity_credential" "app1" {
    depends_on = [
        # These should be automatic , but the blog example shows them as explicit
        module.aks_cluster_pod_ident,
        module.coreinfra,
        azurerm_user_assigned_identity.app1
    ]
    name      = "demo-app1-identity-credentials"
    resource_group_name = module.coreinfra.context.resource_group_name
    audience  = ["api://AzureADTokenExchange"]
    issuer    = module.aks_cluster_pod_ident.oidc_issuer_url 
    subject   = "system:serviceaccount:default:app1"
    parent_id = azurerm_user_assigned_identity.app1.id


  
}
 
 