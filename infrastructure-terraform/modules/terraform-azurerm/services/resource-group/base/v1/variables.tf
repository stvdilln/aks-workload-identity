variable "context" {
  type = object({

    application_name    = string
    environment_name    = string
    location            = string
    location_suffix     = string
  })
}
variable "name" { }
variable "tags" {
  description = "A mapping of tags which should be assigned to all resources"
  type        = map(any)
  default     = {}
}