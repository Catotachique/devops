variable "resources" {
  type = map(object({
    environment = optional(string, "dev")
    name        = string
    region      = optional(string, "westeurope")
  }))
  description = "List of resources."
}