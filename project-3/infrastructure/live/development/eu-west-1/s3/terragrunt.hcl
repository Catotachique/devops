/* Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
components and environments, such as how to configure remote state. */
include {
  path = find_in_parent_folders()
}

/* Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
for the component across all environments. */
include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/s3.hcl"
}

inputs = {
  buckets = {
    "development-assets.clevercorporate.com-felipe" = {
      name             = "development-assets.clevercorporate.com-felipe"
      is_website       = true
      versioning       = "Enabled"
      force_destroy    = true
      cors = [{
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
      }]
    }
    "development-assets.clevercorporate.com-teste" = {
      name = "development-assets.clevercorporate.com-teste"
    }
  }
}