# ndc-open-api-lambda Helm Chart

This chart deploys the ndc-open-api-lambda connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-open-api-lambda" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.NDC_OAS_BASE_URL="ndc_oas_base_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-open-api-lambda | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-open-api-lambda" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.NDC_OAS_BASE_URL="ndc_oas_base_url" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set dataPlane.id="data_plane_id" \
  --set dataPlane.key="data_plane_key" \
  hasura-ddn/ndc-open-api-lambda
```

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Required)                                                                     | `""`                            |
| `connectorEnvVars.NDC_OAS_DOCUMENT_URI`           | The URI of OAS Document. If not provided, the connector will look for `/etc/connector/swagger.json` by default (Optional)                    | `""`                            |
| `connectorEnvVars.NDC_OAS_BASE_URL`               | Base url of the API (Required)                                                                            | `""`                            |
| `connectorEnvVars.NDC_OAS_LAMBDA_PRETTY_LOGS`     | Print logs in a human readable format instead of JSON (Optional)                                          | `"true"`                            |
| `connectorEnvVars.NDC_OAS_FILE_OVERWRITE`         | Overwrite previously generated functions.ts file and api.ts file (Optional)                               | `"false"`                            |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-open-api-lambda                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-open-api-lambda                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `true`                          |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-open-api-lambda pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-open-api-lambda pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-open-api-lambda container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-open-api-lambda                                                                      | `[]`                            |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-open-api-lambda container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-open-api-lambda container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-open-api-lambda container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-open-api-lambda.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |