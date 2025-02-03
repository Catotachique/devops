locals {
  tags = {
    Terraform = true
  }
}

resource "azurerm_resource_group" "this" {
  for_each = var.resources
  name     = each.key
  location = "westeurope"
  tags     = local.tags
}