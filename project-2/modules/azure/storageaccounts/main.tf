locals {
  tags = {
    Terraform = true
  }
}

resource "azurerm_storage_account" "this" {
  for_each                 = var.accounts
  name                     = each.key
  resource_group_name      = each.value.resource_group_name
  location                 = each.value.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}