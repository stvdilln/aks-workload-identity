variable "pg_admin_user_principal_name" {
  description = "The principal name of the PostgreSQL Admin User.  See script set-env.sh for automatic setting of this variable."
  type        = string
}

variable "rg_name" {
  description = "The Name of the Resource Group"
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources"
  type        = map(any)
  default     = {}
}

variable "context" {
  type = object({

    application_name    = string
    environment_name    = string
    location            = string
    location_suffix     = string
  })
}

data http my_ip_address {
  url = "http://ipv4.icanhazip.com"    
}

variable aks_cluster_size {
    default = "small"
}
variable aks_service_offerings {
    type = map(object({
        # Starting Number of Nodes
        node_count     = number
        # Auto Scale Max Nodes
        node_max_count = number
        # Auto Scale Min Nodes
        node_min_count = number
        node_size = string 
    }))
}
