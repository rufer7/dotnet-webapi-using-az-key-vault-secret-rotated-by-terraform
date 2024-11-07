using Azure.Identity;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;

var builder = WebApplication.CreateBuilder(args);

var azureKeyVaultEndpoint = builder.Configuration["AzureKeyVaultEndpoint"];
if (!string.IsNullOrEmpty(azureKeyVaultEndpoint))
{
    // Add Secrets from Azure Key Vault
    builder.Configuration.AddAzureKeyVault(new Uri(azureKeyVaultEndpoint), new ManagedIdentityCredential());
}
else
{
    // Add Secrets from managed user secrets for local development
    builder.Configuration.AddUserSecrets("e5737a3a-d7aa-4968-88ea-f4c0fe1619b9");
}

// Add services to the container
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

builder.Services.AddAuthorizationBuilder()
    .AddPolicy("MyPolicy", policyBuilder =>
        policyBuilder.Requirements.Add(new ScopeAuthorizationRequirement { RequiredScopesConfigurationKey = "AzureAd:Scopes" }));

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
