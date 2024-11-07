# dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform

[![CI/CD](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/actions/workflows/ci-cd.yml)
[![License](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/blob/main/LICENSE)

Rotate Azure Key Vault secrets used by an ASP.NET Core Web API with Terraform on every deployment

## Getting started

### Prerequisites

- [Visual Studio 2022 Preview](https://visualstudio.microsoft.com/vs/preview/)
- [.NET SDK 9.0.100-rc.2](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
- Azure tenant with a subscription and permissions to create resources and app registrations
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=MVP_344197)
- [Terraform 1.9.8](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

### Deploy resources to host terraform state

1. Adjust values in `iac-core\vars\dev.core.tfvars`
1. Create resources to host terraform state by executing the following commands

   ```PowerShell
   az login -t [AZURE_TENANT_ID]
   cd [PATH_TO_REPOSITORY]\iac-core
   terraform init
   terraform apply --var-file=.\vars\dev.core.tfvars --state=dev.core.tfstate
   ```

### Deploy application resources

> [!IMPORTANT]
> To generate deployment credentials and to configure the GitHub secrets for the GitHub actions workflow, see [here](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=openid%2Caspnetcore&WT.mc_id=MVP_344197#set-up-a-github-actions-workflow-manually).
> There are currently two GitHub environments set up for this repository: `dev` and `dev-iac`.
> For both of them a separate federated credential is set up in the Entra app which got created while generating deployment credentials.
> Furthermore the service principal of the Entra app is a member of the Entra group `kv-secret-rotation-sample-contributor-iac` and the following Microsoft Graph application permissions got added
>
> - `Application.ReadWrite.All`
> - `Domain.Read.All`
> - `Group.ReadWrite.All`
>
> Finally, the service principal was assigned the `Owner` role for the resource group.

> [!NOTE]
> The application resources are created via GitHub actions workflow. The following steps are only required, if you want to create the resources manually.

1. Adjust values in `iac\vars\dev.app.tfvars`
1. Adjust values in `iac\backend\dev.backend.tfvars`
1. Create application resources using the following commands

   ```PowerShell
   az login -t [AZURE_TENANT_ID]
   cd [PATH_TO_REPOSITORY]\iac
   terraform init --backend-config=backend\dev.backend.tfvars
   terraform apply --var-file=.\vars\dev.app.tfvars --state=dev.app.tfstate
   ```

### Run application locally

1. Clone this GitHub repository
1. Open the solution `src\ArbitraryAspNetCoreWebApi.sln` in `Visual Studio 2022 Preview`
1. Update the values of the following keys in `appsettings.Development.json`

   - `AzureAd:ClientId` (client id of the app registration with infix `Application` created by Terraform)
   - `AzureAd:Domain` (domain of the Azure tenant)
   - `AzureAd:TenantId` (id of the Azure tenant)

1. Look up the Azure Key Vault secret with name `LocalDevClientSecret`
1. Right click on the project `ArbitraryAspNetCoreWebApi` and select `Manage User Secrets`
1. Add the following content to the `secrets.json` file and replace the value of `ClientSecret` with the secret from the Azure Key Vault

   ```json
   {
     "AzureAd": {
       "ClientSecret": "VALUE_OF_LOCAL_DEV_CLIENT_SECRET"
     }
   }
   ```

1. Right click on the project `ArbitraryAspNetCoreWebApi` and select `Set as Startup Project`
1. Press `F5` to start the application

## Test application

To test the application (either a locally running instance or a deployed one), proceed as follows.

> [!IMPORTANT]
>
> - A client secret for app registration `kv-secret-rotation-sample Client dev` has to be created manually via the Azure portal
> - Admin consent has to be granted for the permissions granted to app registration `kv-secret-rotation-sample Client dev`

1. Request an authorization code by opening the following URL in a browser

   `https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/authorize?client_id={client_app_reg_client_id}&response_type=code&redirect_uri=http://localhost&response_mode=query&scope=api://{web_API_application_client_id}/Forecast.Read`

   - `{tenant_id}`: id of the Azure tenant
   - `{client_app_reg_client_id}`: client id of the app registration with infix `Client` created by Terraform
   - `{web_API_application_client_id}`: client id of the app registration with infix `Application` created by Terraform

1. Copy the authorization code from the URL and use it in the following request in windows command prompt

   ```bash
   curl -X POST https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token ^
    -d "client_id={client_app_reg_client_id}" ^
    -d "api://{web_API_application_client_id}/Forecast.Read" ^
    -d "code={authorization_code}&session_state={client_app_reg_client_id}" ^
    -d "redirect_uri=http://localhost" ^
    -d "grant_type=authorization_code" ^
    -d "client_secret={client_secret}"
   ```

1. Copy the access token from the response and use it in the following request

   ```bash
   curl -X GET https://APPLICATION_BASE_URL:PORT/WeatherForecast ^
    -H "Authorization: Bearer {access_token}"
   ```

> [!NOTE]
> Alternatively, you can use `Postman` to send the requests.

## Useful links

- [Set up a GitHub Actions workflow manually](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=openid%2Caspnetcore&WT.mc_id=MVP_344197#set-up-a-github-actions-workflow-manually)
- [Authenticating using a Service Principal and OpenID Connect](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_oidc)
- [Tutorial: Register a web API with the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/tutorial-web-api-dotnet-register-app?WT.mc_id=MVP_344197)
- [Tutorial: Create and configure an ASP.NET Core project for authentication](https://learn.microsoft.com/en-us/entra/identity-platform/tutorial-web-api-dotnet-prepare-app?WT.mc_id=MVP_344197)
- [Tutorial: Implement a protected endpoint to your API](https://learn.microsoft.com/en-us/entra/identity-platform/tutorial-web-api-dotnet-protect-endpoint?WT.mc_id=MVP_344197)
- [Call an ASP.NET Core web API with cURL](https://learn.microsoft.com/en-us/entra/identity-platform/howto-call-a-web-api-with-curl?tabs=dotnet6%2Cbash&pivots=api&WT.mc_id=MVP_344197)
