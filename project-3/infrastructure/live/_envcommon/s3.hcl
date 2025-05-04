/* This is the common component configuration. 
The common variables for each environment are defined here. */

terraform {
  source = "${path_relative_from_include()}/../../modules//s3"
}

# Locals are named constants that are reusable within the configuration.
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}