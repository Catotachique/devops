variable "buckets" {
  type = map(object({ 
    name             = string
    is_website       = optional(bool, false)
    versioning       = optional(string, "Disabled")
    acl              = optional(string, "private")
    force_destroy    = optional(bool, false)
    cors = optional(list(object({
      allowed_headers = optional(list(string), ["*"])
      allowed_methods = optional(list(string), ["GET", "PUT", "POST", "DELETE"])
      allowed_origins = optional(list(string), ["*"])
      max_age_seconds = optional(number, 1728000)
    })), [])
  }))
  description = "List of buckets."
}