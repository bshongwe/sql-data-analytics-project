terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-sql-analytics"
  location = var.location
}

resource "azurerm_mssql_server" "main" {
  name                         = "sql-analytics-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "main" {
  name           = "DataWarehouseAnalytics"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "S1"
}

resource "azurerm_storage_account" "main" {
  name                     = "storage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "csv" {
  name                  = "csv-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}