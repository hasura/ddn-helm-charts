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

- Save the service account key (JSON) into a file, e.g., `company-sa.json`
- Run Helm by adding the following flags:

```yaml
--set global.dataPlane.deployImagePullSecret=true \
--set global.imagePullSecrets[0]=hasura-image-pull \
--set global.serviceAccount.enabled=true \
--set secrets.imagePullSecret.auths.gcr\.io.username="_json_key" \
--set secrets.imagePullSecret.auths.gcr\.io.email="support@hasura.io" \
--set-file secrets.imagePullSecret.auths.gcr\.io.password=company-sa.json
```

## External Secrets (HashiCorp Vault)

When using an external secrets provider such as HashiCorp Vault, the connector can load sensitive environment variables from JSON files written by the `secrets-management-proxy` init container, instead of from Kubernetes Secrets.

**Note:** HashiCorp Vault projected ServiceAccount token (`projectedToken`) support is available starting with chart version `v2026.05.27` (which bumps the `common` dependency to 0.0.19).

### Prerequisites

1. **HashiCorp Vault** must be running and accessible from the cluster.
2. **Vault Kubernetes auth** must be enabled and configured to trust the cluster's service account issuer.
3. A **Vault KV v2 secret** must exist at the configured path containing the required keys.
4. A **Vault role** must be created that binds the connector's Kubernetes ServiceAccount.
5. The connector image must be the **`-env-loader` variant** (e.g., `ndc-mongodb:v2026.05.19-env-loader`).

### Required Vault Secret Keys

Create a secret in Vault at your configured path (e.g., `secret/mongodb-secrets`) with the following keys:

| Key | Description | Required |
| --- | ----------- | -------- |
| `MONGODB_DATABASE_URI` | MongoDB connection string | Yes |
| `HASURA_SERVICE_TOKEN_SECRET` | Hasura service token secret (from your Supergraph `.env` file) | Optional |

Example using the Vault CLI:

```bash
vault kv put secret/mongodb-secrets \
  MONGODB_DATABASE_URI="mongodb+srv://user:pass@cluster.example.net/mydb?retryWrites=true&w=majority" \
  HASURA_SERVICE_TOKEN_SECRET="my-service-token-secret"
```

### Vault Role Setup

Create a Vault role that authorizes the connector's ServiceAccount:

```bash
vault write auth/kubernetes/role/hasura-secrets \
  bound_service_account_names=ndc-mongodb \
  bound_service_account_namespaces=<your-namespace> \
  policies=hasura-secrets \
  ttl=1h
```

### Example Override File

```yaml
global:
  imagePullSecrets:
    - hasura-image-pull

  # Disable Kubernetes Secret creation — secrets come from Vault
  deploySecrets: false

  externalSecrets:
    enabled: true
    secretName: "mongodb-secrets"
    cloud: hashicorp
    transform:
      mode: "transformed_only"
    hashicorp:
      vaultAddr: "http://vault.vault.svc.cluster.local:8200"
      mount: "secret"
      path: "mongodb-secrets"
      auth:
        method: kubernetes
        role: "hasura-secrets"
        mountPath: "kubernetes"
        # When projectedToken.enabled is true, jwtPath defaults to
        # /var/run/secrets/projectedtokens/vault-token (set by common).
        # Use a projected, audience-bound ServiceAccount token instead of the
        # default SA token for Vault Kubernetes auth.
        projectedToken:
          enabled: true
          audience: "vault"
          expirationSeconds: 7200

# Use the env-loader variant of the connector image
image:
  repository: "gcr.io/hasura-ee/ndc-mongodb"
  tag: "v2026.05.19-env-loader"

# ServiceAccount must match the Vault role's bound_service_account_names
serviceAccount:
  enabled: true
  name: "ndc-mongodb"

externalSecrets:
  enabled: true
  type: initcontainer  # use "sidecar" for automatic secret refresh
  secretRefresher:
    image:
      repository: "gcr.io/hasura-ee/secrets-management-proxy"
      tag: "<secrets-management-proxy-tag>"

# Override the default env block to remove secretKeyRef entries.
# MONGODB_DATABASE_URI and HASURA_SERVICE_TOKEN_SECRET are injected
# by the env-loader entrypoint from /secrets/*.json at startup.
env: |
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: {{ .Values.connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT }}
  - name: OTEL_SERVICE_NAME
    value: ndc-mongodb
```

### How It Works

1. The `secrets-management-proxy` init container authenticates to Vault using the pod's ServiceAccount token and fetches the secret.
2. The secret is written as a JSON file to `/secrets/mongodb-secrets.json` on a shared `emptyDir` volume.
3. The main container uses the `-env-loader` image variant, whose entrypoint script reads every JSON file in `/secrets/`, exports each key/value pair as an environment variable, then execs the connector.
4. The connector starts with `MONGODB_DATABASE_URI` (and any other keys) available as environment variables.

### Init Container vs Sidecar

- **`type: initcontainer`** — secrets are fetched once at startup. If the Vault secret is rotated, a pod restart is required to pick up the new values.
- **`type: sidecar`** — the secret refresher runs alongside the connector and periodically re-fetches secrets (default: every 5 minutes). The connector's env-loader entrypoint only reads secrets at startup, so a pod restart is still needed for the connector to pick up refreshed values. The sidecar mode is useful when combined with other consumers of the `/secrets/` volume.

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
| `serviceAccount.enabled`                          | Enable user of a service account for pod                                                                   | `false`                         |
| `serviceAccount.name`                             | Name for the service account                                                                               | `""`                            |