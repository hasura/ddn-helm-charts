# Ndc-connector-oracle Helm Chart

This chart deploys the ndc-connector-oracle connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template \
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connector.JDBC_URL="jdbc_url" \ 
  --set connector.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-connector-oracle | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connector.JDBC_URL="jdbc_url" \ 
  --set connector.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-connector-oracle

# helm upgrade --install (with OTEL variabes)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/ndc-jvm-oracle" \
  --set image.tag="my_custom_image_tag" \
  --set connector.JDBC_URL="jdbc_url" \ 
  --set connector.HASURA_SERVICE_TOKEN_SECRET="token" \ 
  --set otel.deployOtelCollector="true" \  
  --set otel.dataPlaneID=<data-plane-id> \
  --set otel.dataPlaneKey=<data-plane-key> \
  hasura-ddn/ndc-connector-oracle
```

## Parameters 

| Name                                              | Description                                                                                                | Value                               |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------|
| `image.repository`                                | Image repository containing custom created ndc-connector-oracle                                                     | `""`                                |
| `image.tag`                                       | Image tag to use for custom created ndc-connector-oracle                                                            | `""`                                |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                            |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`      |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                           |
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
| `otel.deployOtelCollector`                        | Deploy OTEL collector as sidecar to ndc-connector-oracle container                                                  | `true`                              |
| `otel.endpoint`                                   | OTEL endpoint under Hasura                                                                                 | `https://gateway.otlp.hasura.io:443`                         |
| `otel.dataPlaneID`                                | Oauth Client ID for pushing telemetry data to endpoint                                                     | `""`                         |
| `otel.dataPlaneKey`                               | Oauth Client Secret for pushing telemetry data to endpoint                                                 | `""`                         |
| `otel.oauthTokenEndpoint`                         | Oauth Token URL                                                                                            | `""`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-connector-oracle pod                                | `[]`                                |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-connector-oracle pod                             | `[]`                                | 
| `resources`                                       | Resource requests and limits of ndc-connector-oracle container                                                      | `{}`                                |
| `env`                                             | Env variable section for ndc-connector-oracle                                                                       | `[]`                                |

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connector.HASURA_SERVICE_TOKEN_SECRET`           | Hasura Service Token Secret (Required)                                                                     | `""`                                 |
| `connector.JDBC_URL`                              | The JDBC URL to connect to the database (Required)                                                                         | `""`                                 |
| `connector.JDBC_SCHEMAS`                          | A comma-separated list of schemas to include in the metadata (Optional)                                                                         | `""`                                 |