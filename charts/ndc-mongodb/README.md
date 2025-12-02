# Ndc-mongodb Helm Chart

This chart deploys the ndc-mongodb connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Connector Image

If you're running `docker compose build` within your Supergraph to build a custom connector image, or if you're using
the **git-sync** option with a Hasura-provided connector image, the base image used in both cases is: `ghcr.io/hasura/ndc-mongodb`

To determine the specific version of the image being used, check the `connector-metadata.yaml` file located under your Supergraph at: `app/connector/<connector-name>/.hasura-connector/connector-metadata.yaml`

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-mongodb" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-mongodb | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-mongodb" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-mongodb
```

## Enabling git-sync

Follow the pre-requisite [here](../../README.md#using-git-for-metadata-files) which has to be done once and deployed on the cluster.

Replace `<git_domain>`, `<org>` and `<repo>` placeholders in the below command to suit your git repository.

Additionally, ensure that `connectorEnvVars.configDirectory` is set to the correct path using the format shown below. Replace `<repo>` with the name of your Git repository, and `<connector-name>` with the name of your connector (found under `app/connector` in your Supergraph repo).  Ensure that you are not adding the `.git` suffix to `<repo>`.

Example: If your repo is `my-repo` and your connector is `my-connector`, the path should be:  `/work-dir/my-repo/app/connector/my-connector`

- Note: For `https` based checkout, a typical URL format for `initContainers.gitSync.repo` will be `https://<git_domain>/<org>/<repo>`.  For `ssh` based checkout, a typical URL format will be `git@<git_domain>:<org>/<repo>`

```bash
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-mongodb" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-mongodb
```

## Committing code to git

When you enable git-sync, the code will be fetched from the repository specified in `initContainers.gitSync.repo`, using the branch defined in `initContainers.gitSync.branch`.

## Configuration Setup Options

The ndc-mongodb connector supports multiple approaches for loading configuration files:

1. **ConfigMap-based configuration** - Load files from Kubernetes ConfigMaps
2. **S3-based configuration** - Download files directly from Amazon S3
3. **Git-sync configuration** - Sync files from a Git repository (see [Enabling git-sync](#enabling-git-sync))

### ConfigMap-Based Configuration Setup

This approach uses external ConfigMaps to provide configuration files. It's useful when you want to manage connector configuration files separately from the Helm chart deployment.

### Configuration Structure

The connector configuration system supports two types of configuration:

1. **Root-level configuration files** - Files placed directly in the connector's root directory
2. **Schema directory configuration files** - Files placed in a `schema/` subdirectory

### Creating ConfigMaps from Files

#### Method 1: Using kubectl create configmap from files

**For root-level configuration files:**
```bash
# Create ConfigMap from individual files
kubectl create configmap connector-root-config \
  --from-file=configuration.json \
  --from-file=connector.yaml
```

**For schema configuration files:**
```bash
# Create ConfigMap from schema directory
kubectl create configmap connector-schema-config \
  --from-file=schema/
```

### Enabling ConfigMap-Based Configuration

To enable ConfigMap-based configuration in your Helm deployment:

```bash
# Enable both root and schema configuration from ConfigMaps
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-mongodb" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set connectorConfig.enabled=true \
  --set connectorConfig.rootConfig.enabled=true \
  --set connectorConfig.rootConfig.configMapName="connector-root-config" \
  --set connectorConfig.schemaConfig.enabled=true \
  --set connectorConfig.schemaConfig.configMapName="connector-schema-config" \
  hasura-ddn/ndc-mongodb
```

### Configuration via values.yaml

Alternatively, you can configure this in your `values.yaml` file:

```yaml
connectorConfig:
  enabled: true

  # Root-level configuration files
  rootConfig:
    enabled: true
    configMapName: "connector-root-config"

  # Schema directory configuration files
  schemaConfig:
    enabled: true
    configMapName: "connector-schema-config"
```

### How It Works

When ConfigMap-based configuration is enabled:

1. **Init Container Setup**: An init container (`setup-connector-config`) runs before the main connector container
2. **File Copying**: The init container copies files from the ConfigMaps to the connector's configuration directory
3. **Directory Structure**:
   - Root config files are copied to `/etc/connector/` (or your specified `mountPath`)
   - Schema config files are copied to `/etc/connector/schema/`
4. **Environment Variable**: The `HASURA_CONFIGURATION_DIRECTORY` environment variable is automatically set to point to the configuration directory

### Complete Example Workflow

1. **Copy connector folder and files from Supergraph to a local folder**

2. **Create ConfigMaps:**
   ```bash
   kubectl create configmap connector-root-config \
     --from-file=configuration.json \
     --from-file=connector.yaml

   kubectl create configmap connector-schema-config \
     --from-file=schema/
   ```

3. **Deploy with ConfigMap configuration:**
   ```bash
   helm upgrade --install my-mongodb-connector \
     --set namespace="default" \
     --set image.repository="my_repo/ndc-mongodb" \
     --set image.tag="my_custom_image_tag" \
     --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
     --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
     --set connectorConfig.enabled=true \
     --set connectorConfig.rootConfig.enabled=true \
     --set connectorConfig.schemaConfig.enabled=true \
     hasura-ddn/ndc-mongodb
   ```

### Benefits of ConfigMap-Based Configuration

- **Separation of Concerns**: Configuration files are managed separately from the Helm chart
- **Version Control**: ConfigMaps can be version controlled independently
- **Dynamic Updates**: Configuration can be updated by updating ConfigMaps and restarting pods
- **Flexibility**: Mix and match root-level and schema configurations as needed
- **Reusability**: Same ConfigMaps can be shared across multiple connector deployments

### Important Limitations

**ConfigMap Size Limits**: ConfigMaps have a maximum size limit of **1 MiB (1,048,576 bytes)** in Kubernetes. This includes all keys and values combined. If your configuration files exceed this limit, consider:

- **Alternative approaches**: Use git-sync for large configuration files
- **File splitting**: Break large configuration files into smaller, more manageable pieces
- **External storage**: Store large files in external storage and reference them in your configuration

**Note**: The 1 MiB limit applies to the entire ConfigMap, not individual files. Monitor your total configuration size when using multiple files in a single ConfigMap.

## S3-Based Configuration Setup

The ndc-mongodb connector also supports downloading configuration files directly from Amazon S3. This approach is ideal for larger configuration files that exceed ConfigMap size limits or when you want to store configuration files in S3.

### S3 Configuration Structure

The S3 configuration system supports:

1. **Individual root files** - Specific files downloaded to the connector's root configuration directory
2. **Schema folder sync** - Entire folder/prefix synced to the `schema/` subdirectory

### AWS Authentication Options

#### Option 1: IAM Roles for Service Accounts (IRSA) - Recommended

When using IRSA, no explicit credentials are needed:

```yaml
connectorConfig:
  s3Config:
    enabled: true
    useIRSA: true
    bucket: "my-config-bucket"
    region: "us-east-1"
```

#### Option 2: AWS Access Keys via Kubernetes Secret

Create a secret with AWS credentials:

```bash
kubectl create secret generic aws-credentials \
  --from-literal=access-key-id="AKIAIOSFODNN7EXAMPLE" \
  --from-literal=secret-access-key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

Then configure the connector:

```yaml
connectorConfig:
  s3Config:
    enabled: true
    useIRSA: false
    credentialsSecret: "aws-credentials"
    bucket: "my-config-bucket"
    region: "us-east-1"
```

### S3 Configuration Examples

#### Downloading Individual Root Files

```yaml
connectorConfig:
  enabled: true
  s3Config:
    enabled: true
    bucket: "my-config-bucket"
    region: "us-east-1"
    useIRSA: true

    rootFiles:
      enabled: true
      files:
        - source: "configuration.json"
          dest: "configuration.json"
        - source: "connector.yaml"
          dest: "connector.yaml"
```

#### Syncing Schema Folder

```yaml
connectorConfig:
  enabled: true
  s3Config:
    enabled: true
    bucket: "my-config-bucket"
    region: "us-east-1"
    useIRSA: true

    schemaFolder:
      enabled: true
      prefix: "schema/"  # Downloads all files from s3://my-config-bucket/schema/
```

#### Combined Root Files and Schema Folder

```yaml
connectorConfig:
  enabled: true
  mountPath: "/etc/connector"
  s3Config:
    enabled: true
    bucket: "my-config-bucket"
    region: "us-east-1"
    useIRSA: true

    rootFiles:
      enabled: true
      files:
        - source: "configuration.json"
          dest: "configuration.json"
        - source: "connector.yaml"
          dest: "connector.yaml"

    schemaFolder:
      enabled: true
      prefix: "schema/"
```

### S3 Deployment Examples

#### Using Helm CLI with IRSA

```bash
helm upgrade --install my-mongodb-connector \
  --set connectorConfig.enabled=true \
  --set connectorConfig.s3Config.enabled=true \
  --set connectorConfig.s3Config.useIRSA=true \
  --set connectorConfig.s3Config.bucket="my-config-bucket" \
  --set connectorConfig.s3Config.region="us-east-1" \
  --set connectorConfig.s3Config.rootFiles.enabled=true \
  --set connectorConfig.s3Config.schemaFolder.enabled=true \
  --set image.repository="ghcr.io/hasura/ndc-mongodb" \
  --set image.tag="v1.0.0" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  hasura-ddn/ndc-mongodb
```

#### Using Helm CLI with AWS Credentials

```bash
# First create the AWS credentials secret
kubectl create secret generic aws-credentials \
  --from-literal=access-key-id="YOUR_ACCESS_KEY" \
  --from-literal=secret-access-key="YOUR_SECRET_KEY"

# Deploy with S3 configuration
helm upgrade --install my-mongodb-connector \
  --set connectorConfig.enabled=true \
  --set connectorConfig.s3Config.enabled=true \
  --set connectorConfig.s3Config.useIRSA=false \
  --set connectorConfig.s3Config.credentialsSecret="aws-credentials" \
  --set connectorConfig.s3Config.bucket="my-config-bucket" \
  --set connectorConfig.s3Config.region="us-east-1" \
  --set connectorConfig.s3Config.rootFiles.enabled=true \
  --set connectorConfig.s3Config.schemaFolder.enabled=true \
  --set image.repository="ghcr.io/hasura/ndc-mongodb" \
  --set image.tag="v1.0.0" \
  --set connectorEnvVars.MONGODB_DATABASE_URI="db_connection_string" \
  hasura-ddn/ndc-mongodb
```

### S3 File Organization

Organize your S3 bucket structure like this:

```
my-config-bucket/
├── configuration.json          # Root configuration file
├── connector.yaml             # Root connector metadata
└── schema/                    # Schema directory
    ├── schema.json           # Schema definition
    ├── metadata.yaml         # Schema metadata
    └── types.json            # Type definitions
```

### How S3 Configuration Works

When S3 configuration is enabled:

1. **Init Container**: Uses `gcr.io/hasura-ee/aws-cli:2.32.7` image with AWS CLI
2. **Authentication**: Either IRSA or explicit AWS credentials from Kubernetes secret
3. **File Download**: Downloads individual files using `aws s3 cp`
4. **Folder Sync**: Syncs entire folders using `aws s3 sync`
5. **Directory Structure**:
   - Root files are downloaded to `/etc/connector/` (or your specified `mountPath`)
   - Schema files are synced to `/etc/connector/schema/`
6. **Environment Variable**: `HASURA_CONFIGURATION_DIRECTORY` is automatically set

### Benefits of S3-Based Configuration

- **No Size Limits**: Unlike ConfigMaps, S3 has no practical size limitations
- **Version Control**: S3 supports object versioning
- **Access Control**: Fine-grained IAM permissions
- **Scalability**: Suitable for large configuration files and complex directory structures
- **Integration**: Works seamlessly with existing AWS infrastructure
- **Security**: Supports IRSA for secure, credential-less access

## Private Registry Access via Image Pull Secrets (GCR Auth Example)

To pull container images from a private registry, such as when deploying connectors hosted in a restricted environment, you can configure an image pull secret using either a YAML override or Helm CLI flags.

- Note: The following example demonstrates authentication using a Google Container Registry (GCR) service account with _json_key authentication.

```yaml
global:
  # Set to true to deploy the image pull secret defined in the `secrets` section
  dataPlane:
    deployImagePullSecret: true

  # Reference the name of the image pull secret to be used
  # This name must remain consistent and match the one defined in the manifest
  imagePullSecrets:
    - hasura-image-pull

  # Enable creation of a service account and attach the image pull secret to it
  serviceAccount:
    enabled: true

secrets:
  imagePullSecret:
    auths:
      gcr.io:
        username: "_json_key"
        # Below content should be replaced with "company-sa.json" file content which is shared by the Hasura team, ensuring that it's indented correctly.
        password: |
          {}
        email: "support@hasura.io"
```

You can achieve the same configuration from the command line using the following steps:

- Save the service account key (JSON) into a file, e.g., `company-sa.json`.  The file will look something like this:

```yaml
{
  "type": "service_account",
  "project_id": "project",
  "private_key_id": "guid",
  ...
  ...
}
```

- Create temporary values file with proper structure (Substitute username and email with proper values):

```bash
cat > /tmp/temp-values.yaml <<'EOF'
secrets:
  imagePullSecret:
    auths:
      gcr.io:
        username: _json_key
        email: support@hasura.io
        password: |
EOF
```

- Append the service account JSON with proper indentation

```bash
cat company-sa.json | sed 's/^/          /' >> /tmp/temp-values.yaml
```

- Run Helm by adding the following flags:

```yaml
--set global.dataPlane.deployImagePullSecret=true \
--set global.imagePullSecrets[0]=hasura-image-pull \
--set global.serviceAccount.enabled=true \
-f /tmp/temp-values.yaml \
```

## Container Level Security Context

By default, no container-level `securityContext` values are set.

To enable them, you can specify the settings you need. For example, the following Helm values configure `readOnlyRootFilesystem: true`, `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, and `drop all` Linux capabilities:

```yaml
--set containerSecurityContext.readOnlyRootFilesystem=true \
--set containerSecurityContext.runAsNonRoot=true \
--set containerSecurityContext.allowPrivilegeEscalation=false \
--set containerSecurityContext.capabilities.drop[0]=ALL
```

You may add any additional fields that are valid container-level Kubernetes `securityContext` options.

**Important Note**

During installation, if you set any value under `containerSecurityContext`, the resulting rendered manifest will include all of the default security settings—merged with the values you explicitly provide.

For example, let's assume that we are only overriding `readOnlyRootFilesystem` to `false`.  The final manifest will look like this:

```yaml
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: false # Only this value was overridden. All other securityContext fields are still included with their default values.
          runAsNonRoot: true
```

These defaults appear even if you did not explicitly configure every field, because the chart merges its defaults with your overrides.

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret.  This value comes from your Supergraph’s `.env` file and corresponds to the connector's `HASURA_SERVICE_TOKEN_SECRET` environment variable. (Optional)                                                                     | `""`                            |
| `connectorEnvVars.MONGODB_DATABASE_URI`           | Database Connection URI (Required)                                                                         | `""`                                 |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT`    | OTEL Exporter OTLP Endpoint (Optional)                                                                     | `"http://dp-otel-collector:4317"`                   |
| `connectorEnvVars.OTEL_SERVICE_NAME`              | OTEL Service Name (Optional)                                                                               | `ndc-mongodb`                  |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                               |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------|
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `additionalAnnotations.checksum/config`           | Adds a checksum annotation for the `secret.yaml` file to force rollout on changes                          | `{{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}`                     |
| `additionalAnnotations.app.kubernetes.io/access-group` | Labels resources with an access group for organizational or access control purposes                   | `connector`                     |
| `networkPolicy.ingress.enabled`                   | Enables ingress network policy rules                                                                       | `true`                          |
| `networkPolicy.ingress.allowedApps`               | Specifies which applications (by label) are allowed ingress access                                         | `v3-engine`                     |
| `global.networkPolicy.enabled`                    | Enables or disables rendering of networkPolicy                                                             | `false`                         |
| `global.dataPlane.deployImagePullSecret`          | Whether to deploy the image pull secret defined in the `secrets` section                                   | `false`                         |
| `global.imagePullSecrets`                         | A list of image pull secret names to use. These must match what is defined in the `secrets` section        | `hasura-image-pull`             |
| `global.serviceAccount.enabled`                   | Enable creation of a Kubernetes service account and attach the image pull secret to it                     | `false`                         |
| `secrets.imagePullSecret.auths.gcr\.io.username`  | Username for authenticating to the container registry                                                      | `_json_key`                     |
| `secrets.imagePullSecret.auths.gcr\.io.password`  | Points to `company-sa.json` file (via `set-file`)                                                          | `company-sa.json`               |
| `secrets.imagePullSecret.auths.gcr\.io.email`     | Email associated with the registry authentication                                                          | `support@hasura.io`             |
| `image.repository`                                | Image repository containing custom created ndc-mongodb                                                     | `""`                                |
| `image.tag`                                       | Image tag to use for custom created ndc-mongodb                                                            | `""`                                |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                            |
| `resources`                                       | Resource requests and limits of ndc-mongodb container                                                      | `{}`                                |
| `env`                                             | Env variable section for ndc-mongodb                                                                       | `[]`                                |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                                 |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                                 |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                                |
| `containerSecurityContext`                        | Define privilege and access control settings for a Container                                               | ``                                |
| `healthChecks.enabled`                            | Enable health check for ndc-mongodb container                                                              | `false`                             |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-mongodb container                                                     | `"/healthz"`                        |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-mongodb container                                                    | `"/healthz"`                        |
| `hpa.enabled`                                     | Enable HPA for ndc-mongodb.  Ensure metrics cluster is configured when enabling                            | `false`                             |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                                 |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                                 |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                                  |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                                  |
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |
| `initContainers.gitSync.secretName`               | Secret name for private key & known hosts (Used when initContainers.gitSync.enabled is set to true)        | `git-creds`                         |
| `initContainers.configSetup.image.repository`     | Image repository for the config setup init container                                                       | `gcr.io/hasura-ee/busybox`                       |
| `initContainers.configSetup.image.tag`            | Image tag for the config setup init container                                                              | `1.37.0`                        |
| `initContainers.configSetup.image.pullPolicy`     | Image pull policy for the config setup init container                                                      | `IfNotPresent`                  |
| `initContainers.s3ConfigSetup.image.repository`   | Image repository for the S3 config setup init container                                                    | `gcr.io/hasura-ee/aws-cli`     |
| `initContainers.s3ConfigSetup.image.tag`          | Image tag for the S3 config setup init container                                                           | `2.32.7`                        |
| `initContainers.s3ConfigSetup.image.pullPolicy`   | Image pull policy for the S3 config setup init container                                                   | `IfNotPresent`                  |
| `connectorConfig.enabled`                         | Enable connector configuration (ConfigMap or S3-based)                                                     | `false`                         |
| `connectorConfig.mountPath`                       | Path where connector configuration files will be mounted                                                   | `"/etc/connector"`              |
| `connectorConfig.rootConfig.enabled`              | Enable root-level configuration files from ConfigMap                                                       | `false`                         |
| `connectorConfig.rootConfig.configMapName`        | Name of ConfigMap containing root-level configuration files                                                 | `"connector-root-config"`       |
| `connectorConfig.schemaConfig.enabled`            | Enable schema directory configuration files from ConfigMap                                                 | `false`                         |
| `connectorConfig.schemaConfig.configMapName`      | Name of ConfigMap containing schema configuration files                                                     | `"connector-schema-config"`     |
| `connectorConfig.s3Config.enabled`                | Enable S3-based configuration download                                                                     | `false`                         |
| `connectorConfig.s3Config.bucket`                 | S3 bucket name containing configuration files                                                              | `"my-config-bucket"`            |
| `connectorConfig.s3Config.region`                 | AWS region for the S3 bucket                                                                              | `"us-east-1"`                   |
| `connectorConfig.s3Config.useIRSA`                | Use IAM Roles for Service Accounts (IRSA) for authentication                                               | `false`                         |
| `connectorConfig.s3Config.credentialsSecret`      | Name of Kubernetes secret containing AWS credentials (when useIRSA=false)                                  | `"aws-credentials"`             |
| `connectorConfig.s3Config.rootFiles.enabled`      | Enable downloading individual root files from S3                                                           | `false`                         |
| `connectorConfig.s3Config.rootFiles.files`        | Array of files to download from S3 (source and dest paths)                                                 | `[]`                            |
| `connectorConfig.s3Config.schemaFolder.enabled`   | Enable syncing schema folder from S3                                                                       | `false`                         |
| `connectorConfig.s3Config.schemaFolder.prefix`    | S3 prefix/folder path for schema files                                                                     | `"schema/"`                     |
| `serviceAccount.enabled`                          | Enable user of a service account for pod                                                                   | `false`                         |
| `serviceAccount.name`                             | Name for the service account                                                                               | `""`                            |