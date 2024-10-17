# ndc-nodejs-lambda Helm Chart

This chart deploys the ndc-nodejs-lambda connector.

## Build Source, render manifests and apply
```bash
helm dep update

# helm template and apply manifests via kubectl (example)
helm template --set global.containerRegistry="my_docker_registry" --set global.namespace="my_namespace" --set image.repository="my_custom_image" --set image.tag="my_custom_image_tag" --set connector.HASURA_SERVICE_TOKEN_SECRET="token" . | kubectl apply -f -

# helm install (with overrides) - WIP
helm install <release name\> TBD/ndc-nodejs-lambda -f overrides.yaml

# helm install (pass configuration via command line) - WIP
helm install <release name\> TBD/ndc-nodejs-lambda --set global.containerRegistry="my_docker_registry" --set global.namespace="my_namespace" --set image.repository="my_custom_image" --set image.tag="my_custom_image_tag" --set connector.HASURA_SERVICE_TOKEN_SECRET="token"
```

## Packaged Helm chart

You can pick the tarball for this Helm chart under https://storage.googleapis.com/hasura-ee-charts/ndc-nodejs-lambda-<helm-chart-version\>.tgz

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
helm install [RELEASE_NAME] TBD/ndc-nodejs-lambda
```
See [configuration](#parameters) below.

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

## Parameters 

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `global.containerRegistry`                        | Global container image registry                                                                            | `""`                            |
| `global.namespace`                                | Namespace to deploy to                                                                                     | `"default"`                     |
| `labels.app`                                      | Common label for ndc-nodejs-lambda connector                                                                    | `"ndc-nodejs-lambda"`                |
| `image.repository`                                | Image repository containing custom created ndc-nodejs-lambda                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-nodejs-lambda                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `image.otelCollectorRepository`                   | OTEL collector image repository                                                                            | `otel/opentelemetry-collector`  |
| `image.otelCollectorTag`                          | OTEL collector image tag                                                                                   | `0.104.0`                       |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `wsInactiveExpiryMins`                            | To be documented                                                                                           | `1`                             |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                            |
| `healthChecks.enabled`                            | Enable health check for ndc-nodejs-lambda container                                                             | `false`                         |
| `healthChecks.livenessProbePath`                  | Health check liveness Probe path ndc-nodejs-lambda container                                                    | `"/healthz"`                    |
| `healthChecks.readinessProbePath`                 | Health check readiness Probe path ndc-nodejs-lambda container                                                   | `"/healthz"`                    |
| `hpa.enabled`                                     | Enable HPA for ndc-nodejs-lambda.  Ensure metrics cluster is configured when enabling                           | `false`                         |
| `hpa.minReplicas`                                 | minReplicas setting for HPA                                                                                | `2`                             |
| `hpa.maxReplicas`                                 | maxReplicas setting for HPA                                                                                | `4`                             |
| `hpa.metrics.resource.name`                       | Resource name to autoscale on                                                                              | ``                              |
| `hpa.metrics.resource.target.averageUtilization`  | Utilization target on specific resource type                                                               | ``                              |
| `otel.deployOtelCollector`                        | Deploy OTEL collector as sidecar to ndc-nodejs-lambda container                                                 | `true`                          |
| `otel.endpoint`                                   | OTEL endpoint under Hasura                                                                                 | `https://gateway.otlp.hasura.io:443`                         |
| `otel.dataPlaneID`                                | Oauth Client ID for pushing telemetry data to endpoint                                                     | `""`                         |
| `otel.dataPlaneKey`                               | Oauth Client Secret for pushing telemetry data to endpoint                                                 | `""`                         |
| `otel.oauthTokenEndpoint`                         | Oauth Token URL                                                                                            | `""`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the ndc-nodejs-lambda pod                               | `[]`                            |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the ndc-nodejs-lambda pod                            | `[]`                               |                               |
| `resources`                                       | Resource requests and limits of ndc-nodejs-lambda container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-nodejs-lambda                                                                      | `[]`                            |

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connector.HASURA_SERVICE_TOKEN_SECRET`           | Hasura Service Token Secret (Required)                                                                     | `""`                            |