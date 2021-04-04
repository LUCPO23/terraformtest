provider "azurerm" {
  skip_provider_registration = true
  features {}
  
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_app_service_plan" "main" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "${var.prefix}-appservice"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  timeouts {
    create = "60m"
    delete = "2h"
  }

  site_config {
    dotnet_framework_version = "v4.0"
    #scm_type = "LocalGit"
    #remote_debugging_enabled = true
    #remote_debugging_version = "VS2019"
  }
  source_control {
    repo_url = "https://github.com/LUCPO23/test-visma.git"
    branch = "master"
  }
}
resource "azurerm_sql_server" "example" {
  name                         = "testsqlserver"
  resource_group_name          = "${var.prefix}-resources"
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "admin"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "testaccount"
  resource_group_name      = "${var.prefix}-resources"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "main" {
  name                = "testdb"
  resource_group_name = "${var.prefix}-resources"
  location            = var.location
  server_name         = "${var.prefix}-sqldb"

  # extended_auditing_policy {
  #   storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
  #   storage_account_access_key              = azurerm_storage_account.example.primary_access_key
  #   storage_account_access_key_is_secondary = true
  #   retention_in_days                       = 6
  # }



  tags = {
    environment = "production"
  }
}
# resource "azurerm_app_service_source_control" "example" {
#   app_service_id        = "${azurerm_app_service.example.id}"
#   repo_url = "https://github.com/bogdilazarescu/ieei.git"
#   is_manual_integration = true
#   branch                = "master"
# }