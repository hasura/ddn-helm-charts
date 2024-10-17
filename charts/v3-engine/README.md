# v3-engine Helm Chart

This chart deploys the v3-engine service.

## Build Source and render manifests and apply
```bash
helm dep update

# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template --release-name <release name> --set image.repository="my_repo/v3-engine" --set image.tag="my_custom_image_tag" . | kubectl apply -f -

# helm upgrade --install (with overrides)
helm upgrade --install <release name> -f overrides.yaml .

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release name> --set image.repository="my_repo/v3-engine" --set image.tag="my_custom_image_tag" .

# helm upgrade --install (with OTEL variabes)
helm upgrade --install <release name> --set image.repository="my_repo/v3-engine" --set image.tag="my_custom_image_tag" --set otel.dataPlaneID=<data-plane-id> --set otel.dataPlaneKey=<data-plane-key> --set otel.hasuraCanonicalHost=<project-name>.<fqdn> .
```

## Packaged Helm chart

You can pick the tarball for this Helm chart under https://storage.googleapis.com/hasura-ee-charts/v3-engine-<helm-chart-version\>.tgz

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
helm install [RELEASE_NAME] v3-engine
```
See [configuration](#parameters) below.

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

## Enabling git-sync

To enable git-sync to read engine and connector config files from a git repository, follow the below steps,

Create a SSH key and grant it *read* access to the repository. It can also be a deploy key, see [set up deploy keys] https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#set-up-deploy-keys

Create a known hosts file, to add GitHub’s SSH host key to your known_hosts file to prevent SSH from asking for confirmation during the connection:
```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

Create a kubernetes secret using the below command,

```bash
kubectl create secret generic git-creds \
  --from-file=ssh=~/.ssh/id_rsa \
  --from-file=known_hosts=~/.ssh/known_hosts
```

## Parameters 

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
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
| `otel.deployOtelCollector`                        | Deploy OTEL collector as sidecar to v3-engine container                                                   | `true`                          |
| `otel.endpoint`                                   | OTEL endpoint under Hasura                                                                                 | `https://gateway.otlp.hasura.io:443`                         |
| `otel.dataPlaneID`                                | Oauth Client ID for pushing telemetry data to endpoint                                                     | `""`                         |
| `otel.dataPlaneKey`                               | Oauth Client Secret for pushing telemetry data to endpoint                                                 | `""`                         |
| `otel.oauthTokenEndpoint`                         | Oauth Token URL                                                                                            | `"https://ddn-oauth.pro.hasura.io/oauth2/token"`                         |
| `otel.hasuraCanonicalHostname`                    | Hasura Canonical Hostname (Project hostname)                                                               | `""`                         |
| `extraVolumes`                                    | Optionally specify extra list of additional volumes for the v3-engine pod                                 | `[]`                               |
| `extraContainers`                                 | Optionally specify extra list of additional containers for the v3-engine pod                              | `[]`                               |
| `securityContext`                                 | Define privilege and access control settings for a Pod or Container                                        | `{}`                               |
| `httpPort`                                        | Running port of v3-engine                                                                                 | `3000`                          |
| `replicas`                                        | Replicas setting for pod                                                                                   | `1`                             |
| `resources`                                       | Resource requests and limits of v3-engine container                                                       | `{}`                               |
| `env`                                             | Env variable section for v3-engine                                                                        | `[]`                               |
