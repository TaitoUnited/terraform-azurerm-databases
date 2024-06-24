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

resource "azurerm_data_protection_backup_vault" "databases" {
  count                        = var.databaseBackupVault.enabled ? 1 : 0

  name                         = "databases"
  resource_group_name          = var.resource_group_name
  location                     = var.databaseBackupVault.location

  # Only vault store is supported for backing up postgresql databases
  datastore_type               = "VaultStore"

  redundancy                   = coalesce(var.databaseBackupVault.redundancy, "LocallyRedundant")
  retention_duration_in_days   = coalesce(var.databaseBackupVault.retentionDurationInDays, 14)
  soft_delete                  = coalesce(var.databaseBackupVault.softDelete, "On")

  identity {
    type = "SystemAssigned"
  }  
}

resource "azurerm_role_assignment" "vault_reader" {
  count                = var.databaseBackupVault.enabled ? 1 : 0

  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.databases[0].identity.0.principal_id
}

/* PostgreSQL backup */

resource "azurerm_role_assignment" "vault_postgres_backup" {
  count                = var.databaseBackupVault.enabled ? 1 : 0

  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  principal_id         = azurerm_data_protection_backup_vault.databases[0].identity.0.principal_id
}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "backup" {
  for_each                        = {for item in local.postgresqlClustersWithVaultBackup: item.name => item}

  name                            = "${each.value.name}-backup"
  vault_id                        = azurerm_data_protection_backup_vault.databases[0].id
  backup_repeating_time_intervals = each.value.vaultBackupSchedule

  default_retention_rule {
    life_cycle {
      duration        = each.value.vaultBackupRetention
      data_store_type = "VaultStore"
    }
  }

  depends_on = [azurerm_role_assignment.vault_reader, azurerm_role_assignment.vault_postgres_backup]
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "postgres" {
  for_each         = {for item in local.postgresqlClustersWithVaultBackup: item.name => item}

  name             = "${each.value.name}-backup"
  location         = each.value.location        # azurerm_resource_group.example.location
  vault_id         = azurerm_data_protection_backup_vault.databases[0].id
  server_id        = azurerm_postgresql_flexible_server.database[each.key].id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.backup[each.key].id
}

/* MySQL backup not yet supported by Azure terraform module? */
