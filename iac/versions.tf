terraform {
  required_version = "~> 1.9.8"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
  }
}
