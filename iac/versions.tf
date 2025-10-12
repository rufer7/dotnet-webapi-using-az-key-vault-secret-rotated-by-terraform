terraform {
  required_version = "~> 1.13.3"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
}
