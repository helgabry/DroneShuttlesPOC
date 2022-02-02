
resource "azurerm_mysql_database" "db" {
  charset             = "utf32"
  collation           = "utf32_general_ci"
  name                = "ghost"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
}

resource "azurerm_mysql_server" "server" {
  administrator_login              = var.mysql_database_username
  administrator_login_password     = var.mysql_database_password
  auto_grow_enabled                = true
  backup_retention_days            = 7
  create_mode                      = "Default"
  geo_redundant_backup_enabled     = false
  location                         = var.primary_location
  name                             = var.mysql_server_name
  public_network_access_enabled    = true
  resource_group_name              = var.resource_group_name
  sku_name                         = "GP_Standard_D2ds_v4"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  storage_mb                       = 51200
  version                          = "8.0.21"
}

resource "azurerm_mysql_server" "server_replica" {
  auto_grow_enabled                = true
  backup_retention_days            = 7
  create_mode                      = "Replica"
  geo_redundant_backup_enabled     = false
  location                         = var.secondary_location
  name                             = "${var.mysql_server_name}_replica"
  public_network_access_enabled    = true
  resource_group_name              = var.resource_group_name
  sku_name                         = "GP_Standard_D2ds_v4" //"GP_Gen5_8"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  storage_mb                       = 51200
  version                          = "8.0.21"
  creation_source_server_id        = azurerm_mysql_server.server.id
}