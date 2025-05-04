terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "287dc8e2-b122-426a-a759-6c6b7e6bc738"
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "tfstatedecoproteste"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"  

  tags = {
    name = "tfstate"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
