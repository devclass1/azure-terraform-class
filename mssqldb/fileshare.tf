# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "fileshare_rg" {
  name     = "rg-fileshare-dev"
  location = "East US"
}

# Create a storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = "stfilesharedev001"
  resource_group_name      = azurerm_resource_group.fileshare_rg.name
  location                 = azurerm_resource_group.fileshare_rg.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  # Disable blob versioning and soft delete to prevent backups
  blob_properties {
    versioning_enabled = false
    delete_retention_policy {
      days = 0
    }
    container_delete_retention_policy {
      days = 0
    }
  }

  # Disable file share soft delete
  share_properties {
    retention_policy {
      days = 0
    }
  }

  tags = {
    Environment = "dev"
    Project     = "fileshare"
  }
}

# Create the file share
resource "azurerm_storage_share" "fileshare" {
  name                 = "myshare"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 100

  # No backup configuration - this ensures no backups are created
}

# Output important information
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage_account.name
}

output "file_share_name" {
  description = "The name of the file share"
  value       = azurerm_storage_share.fileshare.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.fileshare_rg.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.storage_account.id
}

output "file_share_id" {
  description = "The ID of the file share"
  value       = azurerm_storage_share.fileshare.id
}
