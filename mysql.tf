/**
 * Copyright 2024 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_string" "flexible_mysql_admin_password" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  length  = 32
  special = true
  upper   = true

  keepers = {
    username = each.value.adminUsername
  }
}

resource "azurerm_mysql_flexible_server" "database" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.resource_group_name
  version             = each.value.version
  sku_name            = each.value.skuName

  administrator_login               = coalesce(each.value.adminUsername, "root")
  administrator_password            = random_string.flexible_mysql_admin_password[each.key].result

  storage {
    auto_grow_enabled                 = coalesce(each.value.autoGrowEnabled, true)
  }

  backup_retention_days             = coalesce(each.value.backupRetentionDays, 30)
  geo_redundant_backup_enabled      = coalesce(each.value.geoRedundantBackupEnabled, true)

  # TODO: Can't configure a value for "public_network_access_enabled": its value will be decided automatically based on the result of applying this configuration.
  # public_network_access_enabled     = coalesce(each.value.publicNetworkAccessEnabled, false)

  # TODO: threat_detection_policy

  lifecycle {
    prevent_destroy = true
  }
}

/* TODO: enable private DNS
resource "azurerm_private_dns_zone" "mysql" {
  count                 = length(local.oldMysqlClusters) > 0 ? 1 : 0

  name                  = "privatelink.mysql.database.azure.com"
  resource_group_name   = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  count                 = length(local.oldMysqlClusters) > 0 ? 1 : 0

  name                  = "${var.resource_group_name}-mysql"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = true
}
*/

resource "azurerm_private_endpoint" "flexible_mysql" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  name                = "${each.value.name}-endpoint"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${each.value.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_flexible_server.database[each.key].id
    subresource_names              = [ "mysqlServer" ]
    is_manual_connection           = false
  }

  /* TODO: enable private DNS
  private_dns_zone_group {
    name                  = "${each.value.name}-dns-group"
    private_dns_zone_ids  = [ azurerm_private_dns_zone.mysql[0].id ]
  }
  */
}

/* TODO: Open mysql firewall also for some external addresses
resource "azurerm_sql_firewall_rule" "mysql_external_access" {
  for_each            = {for item in local.mysqlClusterAuthorizedNetworks: item.name => item}
  name                = "${each.value.name}-external-access"
  resource_group_name = var.resource_group_name

  server_name         = each.value.name
  start_ip_address    = each.value.startIpAddress
  end_ip_address      = each.value.endIpAddress
}
*/

/* TODO: no longer required?
resource "azurerm_mysql_virtual_network_rule" "database" {
  for_each                             = {for item in local.oldMysqlClusters: item.name => item}

  name                                 = "${each.value.name}-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = each.value.name
  subnet_id                            = var.subnet_id
}
*/
