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

provider "azurerm" {
  features {}
}

locals {
  postgresqlClusters = [
    for postgresql_cluster in coalesce(try(var.postgresql_clusters, []), []):
      postgresql_cluster
    if postgresql_cluster.useOldServer != "true"
  ]

  mysqlClusters = [
    for mysql_cluster in coalesce(try(var.mysql_clusters, []), []):
      mysql_cluster
    if mysql_cluster.useOldServer != "true"
  ]

  oldPostgresqlClusters = [
    for postgresql_cluster in coalesce(try(var.postgresql_clusters, []), []):
      postgresql_cluster
    if postgresql_cluster.useOldServer != "true"
  ]

  oldMysqlClusters = [
    for mysql_cluster in coalesce(try(var.mysql_clusters, []), []):
      mysql_cluster
    if mysql_cluster.useOldServer != "true"
  ]

}
