# App Registration with client secret
resource "random_uuid" "random-uuid-forecast-read" {}

resource "azuread_application" "aadapp" {
  display_name     = format("%s Application %s", var.resource_prefix, var.stage)
  identifier_uris  = []
  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allows the application to read weather forecast data"
      admin_consent_display_name = "Read forecast data"
      enabled                    = true
      id                         = random_uuid.random-uuid-forecast-read.result
      type                       = "User"
      user_consent_description   = "Allows the application to read weather forecast data"
      user_consent_display_name  = "Read forecast data"
      value                      = "Forecast.Read"
    }
  }

  lifecycle {
    ignore_changes = [
      identifier_uris,
    ]
  }
}

resource "azuread_service_principal" "aadapp-sp" {
  client_id = azuread_application.aadapp.client_id

  feature_tags {
    enterprise = true
  }
}

resource "azuread_application_identifier_uri" "aadapp-identifier-uri" {
  application_id = azuread_application.aadapp.id
  identifier_uri = "api://${azuread_application.aadapp.client_id}"
}

resource "azuread_application_password" "aadapppwd" {
  display_name   = "apppwd"
  application_id = azuread_application.aadapp.id
  end_date       = timeadd(timestamp(), "2160h")
}

resource "azurerm_key_vault_secret" "aadapppwd-secret" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "AzureAd--ClientSecret"
  value        = azuread_application_password.aadapppwd.value
}
