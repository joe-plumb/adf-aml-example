terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.44.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "mdw-shared-westeurope-01"
    storage_account_name  = "stmdwsharedwesteurope01"
    container_name        = "enterpriseamlstate"
    key                   = "dev.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

provider "azurerm" {
    features {}
}

resource "random_string" "random" {
  length = 6
  special = false
  upper = false
}

resource "azurerm_resource_group" "rg" {
  name     = "eaml-${var.env}-${var.region}-${random_string.random.result}"
  location = var.region
  tags = var.default_tags
}

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "eaml-adf-${var.env}-${var.region}-${random_string.random.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.default_tags
  
  identity {
    type = "SystemAssigned"
  }

  github_configuration {
            account_name    = "joe-plumb"
            branch_name     = "main" 
            git_url    = "https://github.com"
            repository_name = "adf-aml-example" 
            root_folder     = "/adf"
  }

}

# AML Workspace

resource "azurerm_application_insights" "example" {
  name                = "eaml-ai-${var.env}-${var.region}-${random_string.random.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_key_vault" "kv" {
  name                = "eaml${var.env}${var.regionshort}${random_string.random.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled        = true
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "get", "list", "set", "delete"
    ]

  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_data_factory.adf.identity.0.principal_id
    secret_permissions = [
      "get", "list", "set"
    ]
  }

}

resource "azurerm_storage_account" "example" {
  name                     = "steaml${var.env}${var.regionshort}${random_string.random.result}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_machine_learning_workspace" "example" {
  name                    = "eaml-ws-${var.env}-${var.region}-${random_string.random.result}"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.example.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.example.id

  identity {
    type = "SystemAssigned"
  }
}

# Service Principal for ADF AML Linked Service 
resource "random_password" "password" {
  length = 24
  special = true
  override_special = "_%@"
}

resource "azuread_application" "eamlsp" {
  display_name = "eamlsp${random_string.random.result}"
}

resource "azuread_service_principal" "eamlsp" {
  application_id               = azuread_application.eamlsp.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "example" {
  service_principal_id = azuread_service_principal.eamlsp.id
  value                = random_password.password.result
  end_date_relative    = "8760h"
}

resource "azurerm_key_vault_secret" "kvs_rg" {
  name         = "eamlrg"
  value        = azurerm_resource_group.rg.name
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "eamlwssppw" {
  name         = "eamlws"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

## outputs for ADF json 
output "appId" {
  value = azuread_application.eamlsp.application_id
}

output "tenant"{
  value = data.azurerm_client_config.current.tenant_id
}

output "subscriptionId"{
  value = data.azurerm_client_config.current.subscription_id
}

output "resourceGroupName" {
  value = azurerm_resource_group.rg.name
}

output "mlWorkspaceName" {
  value = azurerm_machine_learning_workspace.example.name
}

output "akv_baseUrl" {
    value = azurerm_key_vault.kv.vault_uri
}

output "location" {
    value = var.region
}

output "env" {
    value = var.env
}

output "adf_name" {
    value = azurerm_data_factory.adf.name
}