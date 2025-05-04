locals {
  tags = {
    Terraform = true
  }
}

resource "azurerm_mssql_server" "this" {
  for_each                     = var.databases
  name                         = each.key
  resource_group_name          = each.value.resource_group_name
  location                     = each.value.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4v3rR53cr37p455w0rD"
}

resource "azurerm_mssql_database" "this" {
  for_each     = var.databases
  name         = each.key
  server_id    = azurerm_mssql_server.this[each.key].id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"
  tags         = local.tags

  # Prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}