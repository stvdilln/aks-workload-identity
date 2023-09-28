output context {
    value = module.my_resource_group.context
}
output observability_settings {
    value = local.observability_settings
}
# random string to avoid naming collisions, only used on 
# Globally named resource (like Log Analytics workspaces)
# We output this so that if something else needs a unique
# name they can use same suffix.
output deploy_suffix {
    value = random_string.deploy_suffix.result
}

