locals {
  tags = {
    Terraform = true
  }
}

resource "azurerm_data_factory" "this" {
  for_each            = var.instances
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = local.tags
}