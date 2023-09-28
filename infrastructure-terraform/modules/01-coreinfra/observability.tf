#
# Log Analytics Workspace
#
module log_analytics {
    source = "../terraform-azurerm/services/log-analytics/workspace/base/v1"
    context = module.my_resource_group.context 
    tags = var.tags
    service_settings = {
        name = "${module.my_resource_group.context.application_name}-${module.my_resource_group.context.environment_name}-workspace-${random_string.deploy_suffix.result}-${module.my_resource_group.context.location_suffix}"
        retention_in_days = 30
    }
}
# LogAnalytics (and Storage) accounts need to have globally unique names
# Given the shared used of this demo, we need to add some 
# randomness so that multiple people can deploy these demos.
resource random_string deploy_suffix {
  length  = 4
  special = false
  upper   = false
}

# 
# App Insights
#
module "appinsights" {
  
  source           = "../terraform-azurerm//services/app-insights/endpoint/base/v1"

  context          = module.my_resource_group.context

  tags = var.tags

  service_settings = {
    name           = "${module.my_resource_group.context.application_name}-${module.my_resource_group.context.environment_name}-${module.my_resource_group.context.location_suffix}"
    retention_in_days = 30
    workspace_id   = module.log_analytics.id  
  }

}

# 
# Log Storage Account
#

module "logs_storage" {
  
  source = "../terraform-azurerm/services/storage/endpoint/base/v1"

  context = module.my_resource_group.context

  tags = var.tags

  service_settings = {
    name                = "logretention"
    tier                = "Standard"
    type                = "LRS"  # RAGRS or something better for production use
  }

}

# 
# Log Storage Container
#
module "appinsight_container" {
  source  = "../terraform-azurerm/services/storage/blob/container/base/v1"
  name    = "logretention"
  storage_account_name = module.logs_storage.name
}

# This can be passed to anything wanting observability_settings
locals {
    observability_settings = {
        instrumentation_key = module.appinsights.instrumentation_key
        workspace_id        = module.log_analytics.id 
        workspace_name      = module.log_analytics.name 
        storage_account     = module.logs_storage.id
        retention_days = 0
    }
}
