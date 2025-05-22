# Ndc-connector-oracle Helm Chart

This chart deploys the ndc-connector-oracle connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Connector Image

If you're running `docker compose build` within your Supergraph to build a custom connector image, or if you're using
the **git-sync** option with a Hasura-provided connector image, the base image used in both cases is: `ghcr.io/hasura/ndc-jvm-oracle`

To determine the specific version of the image being used, check the `connector-metadata.yaml` file located under your Supergraph at: `app/connector/<connector-name>/.hasura-connector/connector-metadata.yaml`

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-connector-oracle | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-connector-oracle
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
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-connector-oracle
```

## Committing code to git

When you enable git-sync, the code will be fetched from the repository specified in `initContainers.gitSync.repo`, using the branch defined in `initContainers.gitSync.branch`.

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret.  This value comes from your Supergraph’s `.env` file and corresponds to the connector's `HASURA_SERVICE_TOKEN_SECRET` environment variable. (Optional)                                                                     | `""`                            |
| `connectorEnvVars.JDBC_URL`                       | The JDBC URL to connect to the database (Required)                                                                         | `""`                                 |
| `connectorEnvVars.JDBC_SCHEMAS`                   | A comma-separated list of schemas to include in the metadata (Optional)                                                                         | `""`                                 |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.QUARKUS_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`                   | Sets the OTLP endpoint to send telemetry data (traces) (Optional)                                                                         | `"http://dp-otel-collector:4317"`                                 |
| `connectorEnvVars.QUARKUS_OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`                   | Sets the OTLP endpoint to send telemetry data (metrics)(Optional)                                                                         | `"http://dp-otel-collector:4317"`                                 |
| `connectorEnvVars.QUARKUS_OTEL_SERVICE_NAME`           | Sets OTEL Service Name (Optional)                                                                         | `"ndc-connector-oracle"`                                 |
| `connectorEnvVars.QUARKUS_DATASOURCE_JDBC_TRACING`                   | Enable or disable tracing for JDBC connections (Optional)                                                                         | `true`                                 |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                               |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------|
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-connector-oracle                                                     | `""`                                |
| `image.tag`                                       | Image tag to use for custom created ndc-connector-oracle                                                            | `""`                                |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                            |
| `resources`                                       | Resource requests and limits of ndc-connector-oracle container                                                      | `{}`                                |
| `env`                                             | Env variable section for ndc-connector-oracle                                                                       | `[]`                                |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                                 |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                                 |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                                |
| `healthChecks.enabled`                            | Enable health check for ndc-connector-oracle container                                                              | `false`                             |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-connector-oracle container                                                     | `"/healthz"`                        |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path mongo-connector container                                                | `"/healthz"`                        |
| `hpa.enabled`                                     | Enable HPA for ndc-connector-oracle.  Ensure metrics cluster is configured when enabling                            | `false`                             |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                                 |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                                 |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                                  |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                                  |
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |
| `initContainers.gitSync.secretName`               | Secret name for private key & known hosts (Used when initContainers.gitSync.enabled is set to true)        | `git-creds`                         |