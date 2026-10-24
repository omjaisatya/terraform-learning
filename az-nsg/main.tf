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

resource "azurerm_resource_group" "rg" {
  name     = "rg-name"
  location = "West India"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "testSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { environment = "Prod" }
}
