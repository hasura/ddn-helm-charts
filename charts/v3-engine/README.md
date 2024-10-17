# V3-engine Helm Chart

This chart deploys the v3-engine service. Refer to the pre-requisites section [here](../../README.md#get-started)

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template \
  --set image.repository="my_repo/v3-engine" \
  --set image.tag="my_custom_image_tag" \
  hasura-ddn/v3-engine | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/v3-engine" \
  --set image.tag="my_custom_image_tag" \
  hasura-ddn/v3-engine

# helm upgrade --install (with OTEL variabes)
helm upgrade --install <release-name> \
  --set image.repository="my_repo/v3-engine" \
  --set image.tag="my_custom_image_tag" \
  --set otel.deployOtelCollector="true" \  
  --set otel.dataPlaneID=<data-plane-id> \
  --set otel.dataPlaneKey=<data-plane-key> \
  --set otel.hasuraCanonicalHost=<project-name>.<fqdn> \
  hasura-ddn/v3-engine
```

## Enabling git-sync

Follow the pre-requisite [here](../../README.md#using-git-for-metadata-files) which has to be done once and deployed on the cluster.

Replace org and repo placeholders in the below command to suit your git repository

```bash
helm upgrade --install <release-name> \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@github.com:<org>/<repo>" \
  --set openDDPath="/work-dir/<repo>/output/open_dd.json" \
  --set authnConfigPath="/work-dir/<repo>/output/auth_config.json" \
  hasura-ddn/v3-engine
```

## Parameters 

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository + image name containing custom created v3-engine                                          | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.tag`                                       | Image tag to use for custom created v3-engine                                                             | `""`                            |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`        |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                              |
| `healthChecks.enabled`                            | Enable health check for v3-engine container                                                               | `true`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path v3-engine container                                                      | `"/health"`                       |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path v3-engine container                                                     | `"/health"`                       |
| `hpa.enabled`                                     | Enable HPA for mongo-connector.  Ensure metrics cluster is configured when enabling                        | `false`                       |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                       |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                       |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                       |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                       |
| `openDDPath`                                      | Path to `opendd.json`                                                                                      | `/md/open_dd.json`              |
| `authnConfigPath`                                 | Path to `auth_config.json`                                                                                 | `/md/auth_config.json`          |
| `metadataPath`                                    | Path to `metadata.json`                                                                                    | `/md/metadata.json`             |
| `enableCors`                                      | Enable CORS by sending appropriate headers                                                                 | `true`                          |
| `observability.enabled`                           | Deploy OTEL collector as sidecar                                                                           | `true`                          |
| `observability.hostName`                          | Hasura Observability Hostname (Required when observability.enabled is set to true)                         | `""`                         |
| `dataPlane.id`                                    | Data Plane ID (Required when observability.enabled is set to true)                                         | `""`                         |
| `dataPlane.key`                                   | Data Plane Key (Required when observability.enabled is set to true)                                        | `""`                         |
| `controlPlane.otlpEndpoint`                       | OTEL endpoint under Hasura                                                                                 | `"https://gateway.otlp.hasura.io:443"`                         |
| `controlPlane.oauthTokenEndpoint`                 | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the v3-engine pod                                 | `[]`                               |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the v3-engine pod                              | `[]`                               |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                               |
| `httpPort`                                        | Running port of v3-engine                                                                                 | `3000`                          |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `resources`                                       | Resource requests and limits of v3-engine container                                                       | `{}`                               |
| `env`                                             | Env variable section for v3-engine                                                                        | `[]`                               |
