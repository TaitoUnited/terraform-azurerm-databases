/**
 * Copyright 2021 Taito United
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
  for_each            = {for item in local.mysqlClusters: item.name => item}

  length  = 32
  special = false
  upper   = true

  keepers = {
    username = each.value.adminUsername
  }
}

resource "azurerm_mysql_server" "database" {
  for_each            = {for item in local.mysqlClusters: item.name => item}

  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.resource_group_name
  version             = each.value.version
  sku_name            = each.value.skuName

  administrator_login               = each.value.adminUsername
  administrator_login_password      = random_string.mysql_admin_password[each.key].result

  storage_mb                        = each.value.storageMb
  auto_grow_enabled                 = each.value.autoGrowEnabled
  backup_retention_days             = each.value.backupRetentionDays
  geo_redundant_backup_enabled      = each.value.geoRedundantBackupEnabled
  infrastructure_encryption_enabled = each.value.infrastructureEncryptionEnabled

  public_network_access_enabled     = each.value.publicNetworkAccessEnabled
  ssl_enforcement_enabled           = each.value.sslEnforcementEnabled
  ssl_minimal_tls_version_enforced  = each.value.sslMinimalTlsVersionEnforced

  # TODO: threat_detection_policy

  lifecycle {
    prevent_destroy = true
  }
}

/* TODO: Open postgres firewall also for some external addresses
resource "azurerm_sql_firewall_rule" "mysql_external_access" {
  for_each            = {for item in local.mysqlClusterAuthorizedNetworks: item.name => item}
  name                = "${each.value.name}-postgres-external-access"
  resource_group_name = var.resource_group_name

  server_name         = each.value.name
  start_ip_address    = each.value.startIpAddress
  end_ip_address      = each.value.endIpAddress
}
*/

resource "azurerm_mysql_virtual_network_rule" "database" {
  for_each                             = {for item in local.mysqlClusters: item.name => item}

  name                                 = "${each.value.name}-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = each.value.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}
