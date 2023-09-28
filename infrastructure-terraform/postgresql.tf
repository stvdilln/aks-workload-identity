locals {
  pg_name = "pg-${var.context.application_name}-${var.context.environment_name}-${var.context.location_suffix}-${random_string.random_suffix.result}"
}
data "azurerm_client_config" "pgconfig" {}

# I am not making this a password because I want to output it 
# for the demo to make life easier.  This is not a best practice.
resource "random_string" "pg_password" {
  length           = 16
  special          = true
  override_special = "@$:()"
}
resource "random_pet" "pg_admin" {
    keepers =  {
      server_name = local.pg_name 
    }
    prefix = "pgadmin"
    separator = ""
    length = 1
}

################################################################### 
# I went to a fair amount of work to create this admin user for the 
# demo.   I don't know how people are logging into Azure, so I figured
# this would be an easy way to get a common login experience.
#
# BUT>>> In order to add AAD users to the database, you need to be an
# Azure AD admin in the database.check 
# I'm leaving this user in, but it's not part of the workload ident
# demo
###################################################################
output "pg_password" {
  value = random_string.pg_password.result
}
output "pg_admin" {
  value = random_pet.pg_admin.id
}
output "pg_host" {
  value = azurerm_postgresql_flexible_server.this.fqdn 
}
output "pg_database" {
  value = azurerm_postgresql_flexible_server_database.test.name
}

resource "azurerm_postgresql_flexible_server" "this" {
    lifecycle {
        ignore_changes = [
            zone
        ]
    }
    name                = random_pet.pg_admin.keepers.server_name
    resource_group_name = module.coreinfra.context.resource_group_name
    location            = module.coreinfra.context.location
    version = "12"
    sku_name = "B_Standard_B1ms"
    storage_mb = 32768
    create_mode = "Default"
    administrator_login = random_pet.pg_admin.id
    administrator_password = random_string.pg_password.result

    authentication {
      active_directory_auth_enabled = true 
      password_auth_enabled = true
      tenant_id = data.azurerm_client_config.pgconfig.tenant_id
    }

}

resource "azurerm_postgresql_flexible_server_database" "test" {
  name                = "test-db"
  server_id           = azurerm_postgresql_flexible_server.this.id
  charset             = "UTF8"
  collation           = "en_US.utf8"  
}

# This is a very open firewall rule, but it is only for the demo
resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "example-fw"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

#
# Create an AD Administrator in the database.  I cannot find a simple
# way to query the 'prinicpal_type'.  I'm going to assume that it is a 
# normal user.  If you are using a Service Principal, you will need to
# change this to 'ServicePrincipal'
#
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin1" {
    server_name         = azurerm_postgresql_flexible_server.this.name
    resource_group_name = module.coreinfra.context.resource_group_name
    tenant_id           = data.azurerm_client_config.pgconfig.tenant_id
    object_id           = data.azurerm_client_config.pgconfig.object_id   
    principal_name      = var.pg_admin_user_principal_name
    principal_type      = "User"
}