locals {
  tags = {
    Terraform = true
  }
}

resource "azurerm_resource_group" "this" {
  for_each = var.resources
  name     = each.key
  location = each.value.location
  tags     = local.tags
}