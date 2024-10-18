# Ndc-connector-phoenix Helm Chart

This chart deploys the ndc-connector-phoenix connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set image.repository="my_repo/ndc-jvm-phoenix" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-connector-phoenix | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/ndc-jvm-phoenix" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.JDBC_URL="jdbc_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-connector-phoenix
```

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Required)                                                                     | `""`                                 |
| `connectorEnvVars.JDBC_URL`                       | The JDBC URL to connect to the database (Required)                                                                         | `""`                                 |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                               |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------|
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-connector-phoenix                                                    | `""`                                |
| `image.tag`                                       | Image tag to use for custom created ndc-connector-phoenix                                                           | `""`                                |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                            |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`      |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                           |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `true`                          |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-connector-phoenix pod                                | `[]`                                |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-connector-phoenix pod                             | `[]`                                |
| `resources`                                       | Resource requests and limits of ndc-connector-phoenix container                                                      | `{}`                                |
| `env`                                             | Env variable section for ndc-connector-phoenix                                                                      | `[]`                                |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                                 |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                                 |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                                |
| `healthChecks.enabled`                            | Enable health check for ndc-connector-phoenix container                                                              | `false`                             |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-connector-phoenix container                                                     | `"/healthz"`                        |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path mongo-connector container                                                | `"/healthz"`                        |
| `hpa.enabled`                                     | Enable HPA for ndc-connector-phoenix.  Ensure metrics cluster is configured when enabling                            | `false`                             |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                                 |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                                 |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                                  |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                                  |