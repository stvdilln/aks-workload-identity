# This is a normal user assigned identity.  When the Azure AD JWT token
# is issued, this is the identity that will be presented to the world.
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

# This is the Glue between the AKS cluster Identity and the 
# azure AD identity.  THe OIDC issure URL is the Identity 
# provider running in the Kubernetes cluster.  Azure AD will 
# work with this Identity provider to validate the Kubernetes
# users identity.
# This is the rosetta stone that pulls it all together.
# The oidc_issuer_url is the link for AzureAD to verify with K8s idp
# the subject is the user in kubernetes that is allowed access
# the parent_id is the target account with the Identity to be assumed
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
    # This is the URL of the Kubernetes Identity Provider
    issuer    = module.aks_cluster_pod_ident.oidc_issuer_url 
    # This is the namespace and service account name that 
    # can use this federated Identity.  (If you don't lock
    # down access to service account creation, then anyone
    # can assume the Azure AD identity.)
    subject   = "system:serviceaccount:default:app1"
    # points to the Azure AD identity that will be 'assumed'
    parent_id = azurerm_user_assigned_identity.app1.id
  
}
 
 