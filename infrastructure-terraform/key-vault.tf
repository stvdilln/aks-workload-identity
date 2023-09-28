data "azurerm_client_config" "kvconfig" {}
locals {
  kv_name = "kv-${var.context.application_name}-${var.context.environment_name}-${var.context.location_suffix}-${random_string.random_suffix.result}"
}

output "kv_name" {
  value = local.kv_name
}
output "AZURE_TENANT_ID" {
  value = data.azurerm_client_config.kvconfig.tenant_id
}

resource "azurerm_key_vault" "vault1" {
    name = local.kv_name
    resource_group_name = module.coreinfra.context.resource_group_name
    location = module.coreinfra.context.location
    enable_rbac_authorization = false 
    tenant_id = data.azurerm_client_config.kvconfig.tenant_id
    sku_name = "standard"
    soft_delete_retention_days = 7  
    network_acls {
        bypass = "None"
        default_action =  "Allow"   
    }


}


resource "azurerm_key_vault_access_policy" "policy" {
    key_vault_id = azurerm_key_vault.vault1.id
    tenant_id = data.azurerm_client_config.kvconfig.tenant_id
    object_id = data.azurerm_client_config.kvconfig.object_id
    storage_permissions = []
    depends_on = [ azurerm_key_vault.vault1 ]
    key_permissions = [ 
        "Backup",
        "Create",
        "Decrypt",
        "Delete",
        "Encrypt",
        "Get",
        "Import",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Sign",
        "UnwrapKey",
        "Update",
        "Verify",
        "WrapKey"
    ]
    secret_permissions = [
        "Backup",
        "Delete",
        "Get",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Set"
    ]
    certificate_permissions = [
        "Backup",
        "Create",
        "Delete",
        "DeleteIssuers",
        "Get",
        "GetIssuers",
        "Import",
        "List",
        "ListIssuers",
        "ManageContacts",
        "ManageIssuers",
        "Purge",
        "Recover",
        "Restore",
        "SetIssuers",
        "Update"
    ]

}

resource "azurerm_key_vault_secret" "big-secret" {
    name = "big-secret"
    value = "Whopper"
    key_vault_id = azurerm_key_vault.vault1.id
    depends_on = [ azurerm_key_vault.vault1 , azurerm_key_vault_access_policy.policy ]
  
}

output "key_vault_uri" {
    value = azurerm_key_vault.vault1.vault_uri
}

resource "azurerm_key_vault_access_policy" "pol1" {
    key_vault_id = azurerm_key_vault.vault1.id
    tenant_id = data.azurerm_client_config.kvconfig.tenant_id
    object_id = azurerm_user_assigned_identity.app1.principal_id
    storage_permissions = []
    key_permissions = [ "Get", "List"]
    secret_permissions = [ "Get", "List"]
    certificate_permissions = ["Get", "List"]
    depends_on = [ azurerm_key_vault.vault1 ]
}
