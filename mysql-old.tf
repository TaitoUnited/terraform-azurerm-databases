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

resource "random_string" "mysql_admin_password" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  length  = 32
  special = true
  upper   = true

  keepers = {
    username = each.value.adminUsername
  }
}

resource "azurerm_mysql_server" "database" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.resource_group_name
  version             = each.value.version
  sku_name            = each.value.skuName

  administrator_login               = coalesce(each.value.adminUsername, "root")
  administrator_login_password      = random_string.mysql_admin_password[each.key].result

  storage_mb                        = coalesce(each.value.storageMb, 20480)
  auto_grow_enabled                 = coalesce(each.value.autoGrowEnabled, true)
  backup_retention_days             = coalesce(each.value.backupRetentionDays, 30)
  geo_redundant_backup_enabled      = coalesce(each.value.geoRedundantBackupEnabled, true)
  infrastructure_encryption_enabled = coalesce(each.value.infrastructureEncryptionEnabled, false)

  public_network_access_enabled     = coalesce(each.value.publicNetworkAccessEnabled, false)
  ssl_enforcement_enabled           = coalesce(each.value.sslEnforcementEnabled, true)
  ssl_minimal_tls_version_enforced  = coalesce(each.value.sslMinimalTlsVersionEnforced, "TLS1_2")

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "mysql" {
  for_each            = {for item in local.oldMysqlClusters: item.name => item}

  name                = "${each.value.name}-endpoint"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${each.value.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.database[each.key].id
    subresource_names              = [ "mysqlServer" ]
    is_manual_connection           = false
  }
}
