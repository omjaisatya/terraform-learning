# Standard Azure Blob Storage Remote Backend Configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprodstorage2026"
    container_name       = "tfstate-container"
    key                  = "production.core.tfstate"

    # Azure Blob Storage automatically provides lease-based state locking.
    # No secondary database (like DynamoDB) is required.
  }
}
