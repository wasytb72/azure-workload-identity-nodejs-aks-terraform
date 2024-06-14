terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.67.0" // Updated the version to the latest version. Original version is 3.1 It did not work.
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
  }
  required_version = ">= 0.14"
}