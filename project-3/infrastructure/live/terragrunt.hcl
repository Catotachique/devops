locals {
  common_vars  = read_terragrunt_config("${get_parent_terragrunt_dir()}/common.hcl")
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  account_id        = local.account_vars.locals.aws_account_id
  account_name      = local.account_vars.locals.account_name
  aws_region        = local.region_vars.locals.aws_region
  default_region    = local.common_vars.locals.default_region
  name_prefix       = local.common_vars.locals.name_prefix
  pgp_key           = local.region_vars.locals.pgp_key
  root_tags         = local.common_vars.locals.root_tags
  tgw_id            = local.region_vars.locals.tgw_id
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.33.0"
      }

      github = {
        source  = "integrations/github"
        version = " 4.28.0"
      }

      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "2.12.1"
      }

      tls = {
        source  = "hashicorp/tls"
        version = "3.4.0"
      }

    }
    required_version = "1.4.5"
  }

  provider "aws" {
    region = "${local.aws_region}"

    # only these aws account ids may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]
  }
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.name_prefix}-${local.account_name}-${local.aws_region}-terraform-state" #catotachique-development-eu-west-1-terraform-state
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-state-locking"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

/* GLOBAL PARAMETERS
These variables apply to all configurations in this subfolder. 
These are automatically merged into the child `terragrunt.hcl` config via the include block.
*/
inputs = {
  # Set commonly used inputs globally to keep child terragrunt.hcl files DRY
  aws_account_id   = local.account_id
  account_name     = local.account_name
  aws_region       = local.aws_region
  tgw_id           = local.tgw_id
  name_prefix      = local.name_prefix
  vpn_cidr         = local.vpn_cidr
  pgp_key          = local.pgp_key
  root_tags        = local.root_tags
}