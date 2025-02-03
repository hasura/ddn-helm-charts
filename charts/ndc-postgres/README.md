# Ndc-Postgres Helm Chart

This chart deploys the ndc-postgres connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-postgres" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.CONNECTION_URI="db_connection_string" \
  hasura-ddn/ndc-postgres | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-postgres" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.CONNECTION_URI="db_connection_string" \
  hasura-ddn/ndc-postgres
```

## Enabling git-sync

Follow the pre-requisite [here](../../README.md#using-git-for-metadata-files) which has to be done once and deployed on the cluster.

Replace `git_domain`, `org` and `repo` placeholders in the below command to suit your git repository.  Additionally, ensure that `connectorEnvVars.configDirectory` is set to the given path below, providing that you are also replacing `repo` and `connector-name` placeholders within it.  For clarity, `connector-name` is the name that was give to your connector (ie. Check `app/connector` under your Supergraph).

Note: For `https` based checkout, a typical URL format for `initContainers.gitSync.repo` will be `https://<git_domain>/<org>/<repo>`.  For `ssh` based checkout, a typical URL format will be `git@<git_domain>:<org>/<repo>`

```bash
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-postgres" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.CONNECTION_URI="db_connection_string" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-postgres
```

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Optional)                                                                     | `""`                            |
| `connectorEnvVars.CONNECTION_URI`                 | Database Connection URI (Required)                                                                         | `""`                            |
| `connectorEnvVars.CLIENT_CERT`                    | Database Client cert (Optional)                                                                            | `""`                            |
| `connectorEnvVars.CLIENT_KEY`                     | Database Client key (Optional)                                                                             | `""`                            |
| `connectorEnvVars.ROOT_CERT`                      | Database Root cert (Optional)                                                                              | `""`                            |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) | `"/etc/connector"`                   |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-postgres                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-postgres                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `false`                         |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-postgres pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-postgres pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-postgres container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-postgres                                                                      | `[]`                            |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-postgres container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-postgres container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-postgres container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-postgres.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |