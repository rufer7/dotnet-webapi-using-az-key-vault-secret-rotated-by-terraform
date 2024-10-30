# Azure App Service Plan and App Service
resource "azurerm_service_plan" "appplan" {
  name                = replace(local.name_template, "<service>", "applan")
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.default_location
  os_type             = "Linux"
  sku_name            = var.app_sku_name
  worker_count        = var.app_worker_count
}

resource "azurerm_linux_web_app" "appsrv" {
  name                = replace(local.name_template, "<service>", "appsrv")
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.default_location
  service_plan_id     = azurerm_service_plan.appplan.id
  https_only          = true
  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    http2_enabled = true
  }
  identity { type = "SystemAssigned" }
  app_settings = merge(
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "AzureAd__ClientId"        = azuread_application.aadapp.client_id
      "AzureAd__Domain"          = data.azuread_domains.aad_domains.domains[0].domain_name
      "AzureAd__TenantId"        = var.tenant_id
      "AzureKeyVaultEndpoint"    = azurerm_key_vault.kv.vault_uri
    }
  )
}