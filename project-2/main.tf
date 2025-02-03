terraform {
  /*
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatedecoproteste"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }*/

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "287dc8e2-b122-426a-a759-6c6b7e6bc738"
}


module "resourcegroups" {
  source = "C:/Users/felip/OneDrive/Documentos/tier0/data-enginner/project-1/modules/azure/resourcegroups"

  resources = {
    deco-dev-resource-groups-data-finance = {
      name = "deco-${var.environment}-resource-groups-data-finance"
    }
    deco-dev-resource-groups-data-quality = {
      name = "deco-${var.environment}-resource-groups-data-quality"  
    }
  }
}
