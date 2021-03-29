# Azure databases

Example usage:

```
provider "azurerm" {
  features {}
}

module "databases" {
  source               = "TaitoUnited/databases/azurerm"
  version              = "1.0.0"

  resource_group_name  = "my-infrastructure"
  subnet_id            = module.network.internal_subnet_id
  private_dns_zone_ids = [ module.network.private_dns_zone_id ]

  postgresql_clusters  = yamldecode(file("${path.root}/../infra.yaml"))["postgresqlClusters"]
  mysql_clusters       = yamldecode(file("${path.root}/../infra.yaml"))["mysqlClusters"]

  # TODO: implement long-term backups
  long_term_backup_bucket = "my-backup"
}
```

Example YAML:

```
postgresqlClusters:
  - name: my-common-postgres
    location: northeurope
    version: "11"
    skuName: GP_Gen5_2
    storageMb: 20480
    autoGrowEnabled: true
    backupRetentionDays: 30
    geoRedundantBackupEnabled: true
    infrastructureEncryptionEnabled: false
    publicNetworkAccessEnabled: false
    sslEnforcementEnabled: true
    sslMinimalTlsVersionEnforced: TLS1_2
    authorizedNetworks:
      - start: 127.127.127.10
        end: 127.127.127.20
    adminUsername: admin

mysqlClusters:
  - name: my-common-mysql
    location: northeurope
    version: "8.0"
    skuName: GP_Gen5_2
    storageMb: 20480
    autoGrowEnabled: true
    backupRetentionDays: 30
    geoRedundantBackupEnabled: true
    infrastructureEncryptionEnabled: false
    publicNetworkAccessEnabled: false
    sslEnforcementEnabled: true
    sslMinimalTlsVersionEnforced: TLS1_2
    authorizedNetworks:
      - start: 127.127.127.10
        end: 127.127.127.20
    adminUsername: admin
```

YAML attributes:

- See variables.tf for all the supported YAML attributes.
- See [postgresql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server) and [mysql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_server) for attribute descriptions.

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/azurerm)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/azurerm)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/azurerm)
- [Compute](https://registry.terraform.io/modules/TaitoUnited/compute/azurerm)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/azurerm)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/azurerm)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/azurerm)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/azurerm)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/azurerm)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Google Cloud, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Azure project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/azurerm), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
