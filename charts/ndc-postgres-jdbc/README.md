# Ndc-postgres-jdbc Helm Chart

This chart deploys the ndc-postgres-jdbc connector (For use under PromptQL use cases). Refer to the pre-requisites section [here](../../README.md#get-started)

## Connector Image

If you're running `docker compose build` within your Supergraph to build a custom connector image, or if you're using
the **git-sync** option with a Hasura-provided connector image, the base image used in both cases is: `ghcr.io/hasura/ndc-postgres-jdbc`

To determine the specific version of the image being used, check the `connector-metadata.yaml` file located under your Supergraph at: `app/connector/<connector-name>/.hasura-connector/connector-metadata.yaml`

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-postgres-jdbc" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-postgres-jdbc | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-postgres-jdbc" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-postgres-jdbc
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
  --set image.repository="my_repo/ndc-postgres-jdbc" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-postgres-jdbc
```

## Committing code to git

When you enable git-sync, the code will be fetched from the repository specified in `initContainers.gitSync.repo`, using the branch defined in `initContainers.gitSync.branch`.

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret.  This value comes from your Supergraph’s `.env` file and corresponds to the connector's `HASURA_SERVICE_TOKEN_SECRET` environment variable. (Optional)                                                                     | `""`                            |
| `connectorEnvVars.JDBC_URL`                 | The JDBC URL to connect to the database (Required)                                                                         | `""`                            |
| `connectorEnvVars.JDBC_SCHEMAS`                   | A comma-separated list of schemas to include in the metadata (Optional)                                                                         | `""`                                 |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT`    | OTEL Exporter OTLP Endpoint (Optional)                                                                     | `"http://dp-otel-collector:4317"`                   |
| `connectorEnvVars.OTEL_SERVICE_NAME`              | OTEL Service Name (Optional)                                                                               | `ndc-postgres-jdbc`                  |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `additionalAnnotations.checksum/config`           | Adds a checksum annotation for the `secret.yaml` file to force rollout on changes                          | `{{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}`                     |
| `additionalAnnotations.app.kubernetes.io/access-group` | Labels resources with an access group for organizational or access control purposes                   | `connector`                     |
| `networkPolicy.ingress.enabled`                   | Enables ingress network policy rules                                                                       | `true`                          |
| `networkPolicy.ingress.allowedApps`               | Specifies which applications (by label) are allowed ingress access                                         | `v3-engine`                     |
| `global.networkPolicy.enabled`                    | Enables or disables rendering of networkPolicy                                                             | `false`                         |
| `image.repository`                                | Image repository containing custom created ndc-postgres-jdbc                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-postgres-jdbc                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `resources`                                       | Resource requests and limits of ndc-postgres-jdbc container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-postgres-jdbc                                                                      | `[]`                            |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-postgres-jdbc container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-postgres-jdbc container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-postgres-jdbc container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-postgres-jdbc.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |
| `initContainers.gitSync.secretName`               | Secret name for private key & known hosts (Used when initContainers.gitSync.enabled is set to true)        | `git-creds`                         |