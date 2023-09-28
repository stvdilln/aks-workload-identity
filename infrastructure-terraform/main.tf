locals {
  default_tags = {
    created-by  = "terraform"
    environment = var.context.environment_name
  }
  all_tags = merge(local.default_tags, var.tags == {} ? null : var.tags)
}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

module coreinfra {
  source  = "./modules/01-coreinfra"
  context = var.context
  name    = "${var.rg_name}-${random_string.random_suffix.result}"
  tags    = local.all_tags
}
