# Ndc-graphql Helm Chart

This chart deploys the ndc-graphql connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set image.repository="my_repo/ndc-graphql" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.GRAPHQL_ENDPOINT="graphql_endpoint" \ 
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-graphql | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/ndc-graphql" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.GRAPHQL_ENDPOINT="graphql_endpoint" \ 
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-graphql
```

## Parameters 

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-graphql                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-graphql                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-graphql container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-graphql container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-graphql container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-graphql.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `true`                          |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-graphql pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-graphql pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-graphql container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-graphql                                                                      | `[]`                            |

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Required)                                                                     | `""`                            |
| `connectorEnvVars.GRAPHQL_ENDPOINT`               | The GraphQL Endpoint (Required)                                                                            | `""`                            |