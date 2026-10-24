terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.74.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "4b6e2efd-6e65-445c-99ad-516f0023f0dc"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-resources"
  location = "West India"
}
