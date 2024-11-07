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
}

resource "azuread_service_principal" "aadapp-sp" {
  client_id = azuread_application.aadapp.client_id
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

resource "azuread_application_password" "localdevapppwd" {
  count          = var.stage == "dev" ? 1 : 0
  display_name   = "localdevapppwd"
  application_id = azuread_application.aadapp.id
  end_date       = timeadd(timestamp(), "17520h")
}

resource "azurerm_key_vault_secret" "localdevapppwd-secret" {
  count        = var.stage == "dev" ? 1 : 0
  key_vault_id = azurerm_key_vault.kv.id
  name         = "LocalDevClientSecret"
  value        = azuread_application_password.aadapppwd.value
}

resource "azuread_application" "postman-aadapp" {
  display_name     = format("%s Postman %s", var.resource_prefix, var.stage)
  identifier_uris  = []
  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2
  }

  required_resource_access {
    resource_app_id = azuread_application.aadapp.id

    resource_access {
      id   = random_uuid.random-uuid-forecast-read.result
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "postman-aadapp-sp" {
  client_id = azuread_application.postman-aadapp.client_id

  feature_tags {
    enterprise = true
  }
}
