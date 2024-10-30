# dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform

[![.NET](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/actions/workflows/dotnet.yml/badge.svg)](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/actions/workflows/dotnet.yml)
[![License](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/rufer7/dotnet-webapi-using-az-key-vault-secret-rotated-by-terraform/blob/main/LICENSE)

Rotate Azure Key Vault secrets used by an ASP.NET Core Web API with Terraform on every deployment

## Getting Started

### Prerequisites

- [Visual Studio 2022 Preview](https://visualstudio.microsoft.com/vs/preview/)
- [.NET SDK 9.0.100-rc.2](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
- Azure tenant with a subscription and permissions to create resources and app registrations
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=MVP_344197)
- [Terraform 1.9.8](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

### Deploy resources to host terraform state

1. Adjust values in `iac-core\vars\dev.core.tfvars`
1. Create resources to host terraform state using the following commands

   ```PowerShell
   az login -t [AZURE_TENANT_ID]
   cd [PATH_TO_REPOSITORY]\iac-core
   terraform init
   terraform apply --var-file .\vars\dev.core.tfvars --state=dev.core.tfstate
   ```

### Deploy application resources

> [!NOTE]  
> The application resources are created via GitHub actions workflow. The following steps are only required if you want to create the resources manually.

1. Adjust values in `iac\vars\dev.app.tfvars`
1. Adjust values in `iac\backend\dev.backend.tfvars`
1. Create resources using the following commands
   
      ```PowerShell
      az login -t [AZURE_TENANT_ID]
      cd [PATH_TO_REPOSITORY]\iac
      terraform init --backend-config=backend\dev.backend.tfvars
      terraform apply --var-file .\vars\dev.app.tfvars --state=dev.app.tfstate
      ```

### Run the Application locally

1. Clone this GitHub repository
1. Open the solution `src\ArbitraryAspNetCoreWebApi.sln` in `Visual Studio 2022 Preview`
1. Update the values of the following keys in `appsettings.Development.json`

   - `AzureAd:ClientId` (client id of the app registration created by Terraform)
   - `AzureAd:Domain`
   - `AzureAd:TenantId`

1. Right click on the project `ArbitraryAspNetCoreWebApi` and select `Set as Startup Project`
1. Press `F5` to start the application
