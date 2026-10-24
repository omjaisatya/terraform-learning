terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4b6e2efd-6e65-445c-99ad-516f0023f0dc"
}
