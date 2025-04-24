# Auth-proxy Helm Chart

This chart deploys the auth-proxy service. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/auth-proxy" \
  --set image.tag="my_custom_image_tag" \
  --set serviceEnvVars.ADFS_PROVIDER_ENDPOINT="adfs_provider_endpoint" \
  --set serviceEnvVars.RESOURCE="resource" \
  --set serviceEnvVars.REGION="region" \
  hasura-ddn/auth-proxy | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/auth-proxy" \
  --set image.tag="my_custom_image_tag" \
  --set serviceEnvVars.ADFS_PROVIDER_ENDPOINT="adfs_provider_endpoint" \
  --set serviceEnvVars.RESOURCE="resource" \
  --set serviceEnvVars.REGION="region" \
  hasura-ddn/auth-proxy
```

## Service ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `serviceEnvVars.ADFS_PROVIDER_ENDPOINT`           | ADFS Provider Endpoint (Required)                                                                          | `""`                            |
| `serviceEnvVars.RESOURCE`                         | Resource (Required)                                                                                        | `""`                            |
| `serviceEnvVars.REGION`                           | Region (Required)                                                                                          | `""`                            |

## Parameters

| Name                                              | Description                                                                                                | Value                               |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------|
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing auth-proxy                                                                     | `""`                                |
| `image.tag`                                       | Image tag to use for custom created auth-proxy                                                             | `""`                                |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                            |
| `resources`                                       | Resource requests and limits of auth-proxy container                                                       | `{}`                                |
| `env`                                             | Env variable section for auth-proxy                                                                        | `[]`                                |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                                 |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                                |
| `healthChecks.enabled`                            | Enable health check for auth-proxy container                                                               | `false`                             |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path auth-proxy                                                                | `"/healthz"`                        |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path auth-proxy                                                               | `"/healthz"`                        |
| `hpa.enabled`                                     | Enable HPA for auth-proxy.  Ensure metrics cluster is configured when enabling                             | `false`                             |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                                 |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                                 |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                                  |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                                  |
