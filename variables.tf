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

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Private network subnet id for databases"
}

variable "postgresql_clusters" {
  type = list(object({
    name = string
    location = string
    version = string
    skuName = string
    storageMb = optional(number)
    autoGrowEnabled = optional(bool)
    backupRetentionDays = optional(number)
    geoRedundantBackupEnabled = optional(bool)
    infrastructureEncryptionEnabled = optional(bool)
    publicNetworkAccessEnabled = optional(bool)
    sslEnforcementEnabled = optional(bool)
    sslMinimalTlsVersionEnforced = optional(string)
    authorizedNetworks = optional(list(object({
      start = string
      end = string
    })))
    adminUsername = optional(string)
  }))
  default = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "mysql_clusters" {
  type = list(object({
    name = string
    location = string
    version = string
    skuName = string
    storageMb = optional(number)
    autoGrowEnabled = optional(bool)
    backupRetentionDays = optional(number)
    geoRedundantBackupEnabled = optional(bool)
    infrastructureEncryptionEnabled = optional(bool)
    publicNetworkAccessEnabled = optional(bool)
    sslEnforcementEnabled = optional(bool)
    sslMinimalTlsVersionEnforced = optional(string)
    authorizedNetworks = optional(list(object({
      start = string
      end = string
    })))
    adminUsername = optional(string)
  }))
  default = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}
