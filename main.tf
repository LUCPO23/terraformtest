provider "azurerm" {
  skip_provider_registration = true
  features {}
  
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

#creating app service plan that we need for the app service itself
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





  tags = {
    environment = "production"
  }
}
