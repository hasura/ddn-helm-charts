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