variable "resources" {
  type = map(object({
    environment         = optional(string, "dev")
    name                = string
    location            = optional(string, "westeurope")
    resource_group_name = optional(string, "")
  }))
  description = "List of resources."
}