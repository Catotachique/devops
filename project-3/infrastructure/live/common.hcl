locals {
  name_prefix      = "catotachique"
  organization_arn = "arn:aws:organizations::449381706500:organization/o-y8fei7p3g4"
  default_region   = "eu-west-1"
  vpn_cidr         = "10.212.134.0/24"
  root_tags = {
    terraform    = true
  }
}