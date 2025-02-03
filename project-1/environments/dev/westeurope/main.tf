terraform {
  /*
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatedecoproteste"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  */

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
    rg-data-storage = {
      name = "rg-data-storage"
    }
    rg-data-ingestion = {
      name = "rg-data-ingestion"
    }
    rg-data-processing = {
      name = "rg-data-processing"
    }
    rg-data-analytics = {
      name = "rg-data-analytics"
    }
    rg-data-governance = {
      name = "rg-data-governance"
    }
    rg-monitoring-orchestration = {
      name = "rg-monitoring-orchestration"
    }
  }
}

module "storageaccount" {
  source = "C:/Users/felip/OneDrive/Documentos/tier0/data-enginner/project-1/modules/azure/storageaccounts"

  accounts = {
    sadeproject1 = {
      name                = "sadeproject1"
      resource_group_name = module.resourcegroups.resource_group_name_data_storage
      location            = "westeurope"
      is_hns_enabled      = true
    }
  }
}

module "datafactory" {
  source = "C:/Users/felip/OneDrive/Documentos/tier0/data-enginner/project-1/modules/azure/datafactory"

  instances = {
    df-de-project-1 = {
      name                = "df-de-project-1"
      resource_group_name = module.resourcegroups.resource_group_name_data_ingestion
    }
  }
}
