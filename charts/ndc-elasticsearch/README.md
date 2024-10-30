# Ndc-elasticsearch Helm Chart

This chart deploys the ndc-elasticsearch connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-elasticsearch" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.ELASTICSEARCH_URL="elasticsearch_url" \
  --set connectorEnvVars.ELASTICSEARCH_USERNAME="elasticsearch_username" \
  --set connectorEnvVars.ELASTICSEARCH_PASSWORD="elasticsearch_password" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-elasticsearch | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-elasticsearch" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.ELASTICSEARCH_URL="elasticsearch_url" \
  --set connectorEnvVars.ELASTICSEARCH_USERNAME="elasticsearch_username" \
  --set connectorEnvVars.ELASTICSEARCH_PASSWORD="elasticsearch_password" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-elasticsearch
```

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Required)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_URL`    | The comma-separated list of Elasticsearch host addresses for connection (Required)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_USERNAME`               | The username for authenticating to the Elasticsearch cluster (Required)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_PASSWORD`               | The password for the Elasticsearch user account (Required)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_API_KEY`               | The Elasticsearch API key for authenticating to the Elasticsearch cluster (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CA_CERT_PATH`               | The path to the Certificate Authority (CA) certificate for verifying the Elasticsearch server's SSL certificate (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_INDEX_PATTERN`               | The pattern for matching Elasticsearch indices, potentially including wildcards, used by the connector (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_DEFAULT_RESULT_SIZE`               | The default query size when no limit is applied. Defaults to 10,000 (Optional)                                                                            | `""`                            |


## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-elasticsearch                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-elasticsearch                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `true`                          |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-elasticsearch pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-elasticsearch pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-elasticsearch container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-elasticsearch                                                                      | `[]`                            |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-elasticsearch container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-elasticsearch container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-elasticsearch container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-elasticsearch.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |