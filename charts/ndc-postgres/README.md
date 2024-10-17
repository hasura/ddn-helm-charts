# ndc-postgres Helm Chart

This chart deploys the ndc-postgres connector.

## Build Source, render manifests and apply
```bash
helm dep update

# helm template and apply manifests via kubectl (example)
helm template --release-name <release name> --set image.repository="my_custom_image" --set image.tag="my_custom_image_tag" --set connector.CONNECTION_URI="db_connection_string" --set connector.HASURA_SERVICE_TOKEN_SECRET="token" . | kubectl apply -f -

# helm install (with overrides) - WIP
helm upgrade --install <release name\> TBD/ndc-postgres -f overrides.yaml

# helm install (pass configuration via command line) - WIP
helm upgrade --install <release name\> TBD/ndc-postgres --set image.repository="my_custom_image" --set image.tag="my_custom_image_tag" --set connector.CONNECTION_URI="db_connection_string" --set connector.HASURA_SERVICE_TOKEN_SECRET="token"
```

## Packaged Helm chart

You can pick the tarball for this Helm chart under https://storage.googleapis.com/hasura-ee-charts/ndc-postgres-<helm-chart-version\>.tgz

## Prerequisites

1. Helm (preferably v3) installed – instructions are [here](https://helm.sh/docs/intro/install/).
2. Hasura helm repo configured.
  
```bash
helm repo add hasura https://hasura.github.io/helm-charts
helm repo update
```

> You can change the repo name `hasura` to another one if getting conflicts.

## Get Started

```bash
helm install [RELEASE_NAME] TBD/ndc-postgres
```
See [configuration](#parameters) below.

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

## Parameters 

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |               |
| `image.repository`                                | Image repository containing custom created ndc-postgres                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-postgres                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
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
| `otel.deployOtelCollector`                        | Deploy OTEL collector as sidecar to ndc-postgres container                                                 | `true`                          |
| `otel.endpoint`                                   | OTEL endpoint under Hasura                                                                                 | `https://gateway.otlp.hasura.io:443`                         |
| `otel.dataPlaneID`                                | Oauth Client ID for pushing telemetry data to endpoint                                                     | `""`                         |
| `otel.dataPlaneKey`                               | Oauth Client Secret for pushing telemetry data to endpoint                                                 | `""`                         |
| `otel.oauthTokenEndpoint`                         | Oauth Token URL                                                                                            | `""`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-postgres pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-postgres pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-postgres container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-postgres                                                                      | `[]`                            |

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connector.HASURA_SERVICE_TOKEN_SECRET`           | Hasura Service Token Secret (Required)                                                                     | `""`                            |
| `connector.CONNECTION_URI`                        | Database Connection URI (Required)                                                                         | `""`                            |
| `connector.CLIENT_CERT`                           | Database Client cert (Optional)                                                                            | `""`                            |
| `connector.CLIENT_KEY`                            | Database Client key (Optional)                                                                             | `""`                            |
| `connector.ROOT_CERT`                             | Database Root cert (Optional)                                                                              | `""`                            |