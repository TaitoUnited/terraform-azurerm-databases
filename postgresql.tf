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

resource "random_string" "postgresql_admin_password" {
  for_each            = {for item in local.postgresqlClusters: item.name => item}

  length  = 32
  special = false
  upper   = true

  keepers = {
    username = each.value.adminUsername
  }
}

resource "azurerm_postgresql_server" "database" {
  for_each            = {for item in local.postgresqlClusters: item.name => item}

  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.resource_group_name
  version             = each.value.version
  sku_name            = each.value.skuName

  administrator_login               = try(each.value.adminUsername, "postgres")
  administrator_login_password      = random_string.postgresql_admin_password[each.key].result

  storage_mb                        = try(each.value.storageMb, 20480)
  auto_grow_enabled                 = try(each.value.autoGrowEnabled, true)
  backup_retention_days             = try(each.value.backupRetentionDays, 30)
  geo_redundant_backup_enabled      = try(each.value.geoRedundantBackupEnabled, true)
  infrastructure_encryption_enabled = try(each.value.infrastructureEncryptionEnabled, false)

  public_network_access_enabled     = try(each.value.publicNetworkAccessEnabled, false)
  ssl_enforcement_enabled           = try(each.value.sslEnforcementEnabled, true)
  ssl_minimal_tls_version_enforced  = try(each.value.sslMinimalTlsVersionEnforced, "TLS1_2")

  # TODO: threat_detection_policy

  lifecycle {
    prevent_destroy = true
  }
}

/* TODO: Open postgres firewall also for some external addresses
resource "azurerm_sql_firewall_rule" "postgres_external_access" {
  for_each            = {for item in local.postgresqlClusterAuthorizedNetworks: item.name => item}
  name                = "${each.value.name}-external-access"
  resource_group_name = var.resource_group_name

  server_name         = each.value.name
  start_ip_address    = each.value.startIpAddress
  end_ip_address      = each.value.endIpAddress
}
*/

resource "azurerm_postgresql_virtual_network_rule" "database" {
  for_each                             = {for item in local.postgresqlClusters: item.name => item}

  name                                 = "${each.value.name}-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = each.value.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}
