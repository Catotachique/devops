variable "databases" {
  type = map(object({
    environment         = optional(string, "dev")
    name                = string
    location            = optional(string, "westeurope")
    resource_group_name = optional(string, "")
    is_hns_enabled      = optional(bool, false)
  }))
  description = "List of SQL servers."
}