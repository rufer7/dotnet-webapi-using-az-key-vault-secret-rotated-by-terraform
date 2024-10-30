# App Registration with client secret
resource "azuread_application" "aadapp" {
  display_name     = format("%s Application %s", var.resource_prefix, var.stage)
  identifier_uris  = []
  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2
  }
}

resource "azuread_application_password" "aadapppwd" {
  display_name      = "apppwd"
  application_id    = azuread_application.aadapp.id
  end_date_relative = "17520h"
}

resource "azurerm_key_vault_secret" "aadapppwd-secret" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "AzureAd--ClientSecret"
  value        = azuread_application_password.aadapppwd.value
}
