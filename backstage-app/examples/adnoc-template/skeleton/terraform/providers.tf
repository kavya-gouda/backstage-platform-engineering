terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }

  # Note: For production, consider adding a remote backend configuration here 
  # (e.g., Azure Blob Storage) to persist your state file across workflow runs.
}

provider "azurerm" {
  features {}
  # Credentials are pulled automatically from ARM_* environment variables set in GitHub Actions
}
