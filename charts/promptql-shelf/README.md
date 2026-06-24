# promptql-shelf

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://lakekeeper.github.io/lakekeeper-charts/ | lakekeeper | 0.8.1 |
| https://trinodb.github.io/charts/ | trino | 1.41.0 |
| oci://us-west1-docker.pkg.dev/hasura-ee/helm-charts | common | 0.0.16 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lakekeeper.authz.backend | string | `"allowall"` | Authorization backend type |
| lakekeeper.bootstrap.annotations | object | `{"helm.sh/hook":"post-install","helm.sh/hook-delete-policy":"before-hook-creation"}` | Annotations for the bootstrap job |
| lakekeeper.bootstrap.apiUrl | string | `"http://lakekeeper.promptql.svc.cluster.local:8181"` | API URL for lakekeeper bootstrap |
| lakekeeper.bootstrap.azdlsFilesystem | string | `""` | Azure Data Lake Storage filesystem name (Azure) |
| lakekeeper.bootstrap.azdlsStorageAccount | string | `""` | Azure Data Lake Storage account name (Azure) |
| lakekeeper.bootstrap.cloud | string | `"aws"` | Cloud provider for bootstrap (aws, gcp, azure) |
| lakekeeper.bootstrap.gcsBucket | string | `""` | GCS bucket name for storage (GCP) |
| lakekeeper.bootstrap.s3Bucket | string | `""` | S3 bucket name for storage (AWS) |
| lakekeeper.bootstrap.s3Region | string | `""` | S3 region for storage (AWS) |
| lakekeeper.bootstrap.warehouseName | string | `"iceberg"` | Warehouse name for Iceberg catalog |
| lakekeeper.catalog.config | object | `{"LAKEKEEPER__ENABLE_AWS_SYSTEM_CREDENTIALS":"true","LAKEKEEPER__ENABLE_AZURE_SYSTEM_CREDENTIALS":"true","LAKEKEEPER__ENABLE_GCP_SYSTEM_CREDENTIALS":"true"}` | Catalog configuration environment variables |
| lakekeeper.catalog.replicas | int | `2` | Number of replicas to deploy. Replicas are stateless. |
| lakekeeper.catalog.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"250m","memory":"256Mi"}}` | Resource limits and requests for the catalog container |
| lakekeeper.enabled | bool | `true` | Enable or disable the lakekeeper subchart |
| lakekeeper.externalDatabase.database | string | `"lakekeeper"` | The database/schema to use within the external database |
| lakekeeper.externalDatabase.host_read | string | `""` | hostname to use for read instances of the external database |
| lakekeeper.externalDatabase.host_write | string | `""` | hostname to use for write instances of the external database. For single read/write instances, this should be the same as `host_read` |
| lakekeeper.externalDatabase.password | string | `""` | The password for the external database. |
| lakekeeper.externalDatabase.port | int | `5432` | Port of the external database |
| lakekeeper.externalDatabase.type | string | `"postgres"` | the type of external database. allowed values: "postgres" |
| lakekeeper.externalDatabase.user | string | `""` | The username for the external database |
| lakekeeper.fullnameOverride | string | `"lakekeeper"` | Override the fullname of lakekeeper resources |
| lakekeeper.pgEncryptionKey | string | `""` | PostgreSQL encryption key (leave empty to use secret) |
| lakekeeper.postgresql.enabled | bool | `false` | Enable built-in PostgreSQL (set to false when using external database) |
| lakekeeper.preInstallMigration.annotations | object | `{"helm.sh/hook":"pre-install","helm.sh/hook-delete-policy":"before-hook-creation"}` | Annotations for the pre-install migration job |
| lakekeeper.secretBackend.postgres.encryptionKeySecret | string | `"lakekeeper-pg-encryption"` | Name of the secret containing the encryption key. (Mandatory) |
| lakekeeper.secretBackend.postgres.encryptionKeySecretKey | string | `"encryptionKey"` | Name of the key within `encryptionKeySecret` containing the encryption key string |
| lakekeeper.secretBackend.type | string | `"Postgres"` | the type of secret store to use. Available values: "Postgres", "KV2" |
| lakekeeper.serviceAccount.create | bool | `true` | Specifies whether a service account should be created. If `false`, you must create the service account outside this chart with name: `serviceAccount.name` |
| trino.catalogs | string | `""` | Trino catalogs configuration |
| trino.cloud | string | `"aws"` | Cloud provider for trino (aws, gcp, azure) |
| trino.coordinator.additionalVolumeMounts | list | `[{"mountPath":"/etc/trino/catalog","name":"trino-catalog"}]` | Additional volume mounts for the coordinator container |
| trino.coordinator.additionalVolumes | list | `[{"configMap":{"name":"trino-catalog"},"name":"trino-catalog"}]` | Additional volumes for the coordinator pod |
| trino.coordinator.resources | object | `{"limits":{"cpu":"2000m","memory":"4Gi"},"requests":{"cpu":"1000m","memory":"2Gi"}}` | Resource limits and requests for the coordinator container |
| trino.enabled | bool | `true` | Enable or disable the trino subchart |
| trino.fullnameOverride | string | `"trino"` | Override the fullname of trino resources |
| trino.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| trino.serviceAccount.name | string | `"trino"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| trino.worker.additionalVolumeMounts | list | `[{"mountPath":"/etc/trino/catalog","name":"trino-catalog"}]` | Additional volume mounts for the worker containers |
| trino.worker.additionalVolumes | list | `[{"configMap":{"name":"trino-catalog"},"name":"trino-catalog"}]` | Additional volumes for the worker pods |
| trino.worker.resources | object | `{"limits":{"cpu":"4000m","memory":"8Gi"},"requests":{"cpu":"2000m","memory":"4Gi"}}` | Resource limits and requests for the worker containers |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
