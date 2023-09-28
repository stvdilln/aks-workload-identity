output AZURE_RESOURCE_GROUP {
    value = module.coreinfra.context.resource_group_name
}
output AZURE_KUBERNETES_CLUSTER_NAME {
    value = module.aks_cluster_pod_ident.name
}
output AZURE_KUBERNETES_OIDC_ISSUER_URL {
    value = module.aks_cluster_pod_ident.oidc_issuer_url
}
output kubernetes_authorized_ip_address {
    value = "${chomp(data.http.my_ip_address.response_body)}"
}