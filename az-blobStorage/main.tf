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

resource "azurerm_resource_group" "blob-rg" {
  name     = "blob"
  location = "Central India"
}

resource "azurerm_data_share_account" "name" {
  name                = "example_blob"
  location            = azurerm_resource_group.blob-rg.location
  resource_group_name = azurerm_resource_group.blob-rg.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_share" "data_share" {
  name       = "share-ex"
  account_id = azurerm_data_share_account.name.id
  kind       = "CopyBased"
}

resource "azurerm_storage_account" "storage-account" {
  name                     = "storagestr"
  resource_group_name      = azurerm_resource_group.blob-rg.name
  location                 = azurerm_resource_group.blob-rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "container-sc"
  storage_account_id    = azurerm_storage_account.storage-account.id
  container_access_type = "container"
}

data "azuread_service_principal" "sv-principle" {
  display_name = azurerm_data_share_account.name.name
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.storage-account.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_service_principal.sv-principle.id
}


resource "azurerm_data_share_dataset_blob_storage" "blob" {
  name           = "dsbsds-file"
  data_share_id  = azurerm_data_share.data_share.id
  container_name = azurerm_storage_container.example.name
  storage_account {
    name                = azurerm_storage_account.storage-account.name
    resource_group_name = azurerm_storage_account.storage-account.name
    subscription_id     = "4b6e2efd-6e65-445c-99ad-516f0023f0dc"
  }
  file_path = "myfile.txt"
  depends_on = [
    azurerm_role_assignment.example,
  ]
}
