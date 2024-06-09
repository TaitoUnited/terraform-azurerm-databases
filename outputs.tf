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

output "postgresql_hosts" {
  description = "PostgreSQL hosts"
  value       = concat(
    values(azurerm_private_endpoint.postgresql)[*].private_service_connection[0].private_ip_address,
    values(azurerm_private_endpoint.flexible_postgresql)[*].private_service_connection[0].private_ip_address
  )
  # TODO: enable private DNS:
  # value       = values(azurerm_private_endpoint.postgresql)[*].custom_dns_configs[0].fqdn
}

output "mysql_hosts" {
  description = "MySQL hosts"
  value       = concat(
    values(azurerm_private_endpoint.mysql)[*].private_service_connection[0].private_ip_address,
    values(azurerm_private_endpoint.flexible_mysql)[*].private_service_connection[0].private_ip_address
  )
  # TODO: enable private DNS:
  # value       = values(azurerm_private_endpoint.mysql)[*].custom_dns_configs[0].fqdn
}

output "postgresql_ip_addresses" {
  description = "PostgreSQL IP addresses"
  value       = concat(
    values(azurerm_private_endpoint.postgresql)[*].private_service_connection[0].private_ip_address,
    values(azurerm_private_endpoint.flexible_postgresql)[*].private_service_connection[0].private_ip_address,
  )
}

output "mysql_ip_addresses" {
  description = "MySQL IP addresses"
  value       = concat(
    values(azurerm_private_endpoint.mysql)[*].private_service_connection[0].private_ip_address,
    values(azurerm_private_endpoint.flexible_mysql)[*].private_service_connection[0].private_ip_address
  )
}
