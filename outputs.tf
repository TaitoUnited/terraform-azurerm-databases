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

output "postgresql_hosts" {
  description = "Postgres hosts"
  value       = [ "TODO" ] # azurerm_private_endpoint.postgresql[*].custom_dns_configs[0].fqdn
}

output "mysql_hosts" {
  description = "MySQL hosts"
  value       = [ "TODO" ] # azurerm_private_endpoint.mysql[*].custom_dns_configs[0].fqdn
}

# ----- TODO: remove ---------

output "postgresql_details" {
  description = "postgresql_endpoint_details"
  value       = azurerm_postgresql_server.database[*]
}

output "mysql_details" {
  description = "mysql_endpoint_details"
  value       = azurerm_mysql_server.database[*]
}

output "postgresql_endpoint_details" {
  description = "postgresql_endpoint_details"
  value       = azurerm_private_endpoint.postgresql[*]
}

output "mysql_endpoint_details" {
  description = "mysql_endpoint_details"
  value       = azurerm_private_endpoint.mysql[*]
}
