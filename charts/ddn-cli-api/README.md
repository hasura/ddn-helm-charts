# Ddn-cli-api Helm Chart

This chart deploys ddn-cli-api.

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="<namespace>" \
  --set global.domain="<ingress-domain>" \
  --set global.subDomain="false" \
  --set global.containerRegistry="gcr.io/hasura-ee" \
  --set image.repository="ddn-cli-api" \
  --set image.tag="v0.1.1-a4f050b.1" \
  --set ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT="<data_graphql_endpoint>" \
  --set ddnCliApiEnvVars.HASURA_DDN_CONSOLE_HOST="<console_host>" \
  hasura-ddn/ddn-cli-api | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="<namespace>" \
  --set global.domain="<ingress-domain>" \
  --set global.subDomain="false" \
  --set global.containerRegistry="gcr.io/hasura-ee" \
  --set image.repository="ddn-cli-api" \
  --set image.tag="v0.1.1-a4f050b.1" \
  --set ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT="<data_graphql_endpoint>" \
  --set ddnCliApiEnvVars.HASURA_DDN_CONSOLE_HOST="<console_host>" \
  hasura-ddn/ddn-cli-api

# helm template and create a service account with supplied image pull secret
helm template v1 \
  --set namespace="<namespace>" \
  --set global.domain="<ingress-domain>" \
  --set global.subDomain="false" \
  --set global.containerRegistry="gcr.io/hasura-ee" \
  --set global.imagePullSecrets[0]="hasura-image-pull" \
  --set serviceAccount.enabled="true " \
  --set image.repository="ddn-cli-api" \
  --set image.tag="v0.1.1-a4f050b.1" \
  --set ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT="<data_graphql_endpoint>" \
  --set ddnCliApiEnvVars.HASURA_DDN_CONSOLE_HOST="<console_host>" \
  hasura-ddn/ddn-cli-api
```

## Image pull secret

The DDN Workspace Helm chart is configured by default to fetch from Hasura's own private registry.  You will need to obtain an image pull secret in order to pull from this registry or otherwise
contact the Hasura engineering team in order to obtain alternate methods for fetching the image.

## Images

Contact Hasura engineering team for this information.

## Custom Environment variables (For Custom CLI Hooks)

Let's assume you want to add custom validation hooks per instructions [here](https://https://ddn-cp-docs.hasura.io//control-plane/guides/cli-wrapper/#custom-cli-hooks).  When running either `helm template` or `helm upgrade` command, you will also need to pass these as installation parameters:

```yaml
--set additionalEnv[0].name="ENABLE_CUSTOM_HOOK" --set additionalEnv[0].value=true \
--set additionalEnv[0].name="CUSTOM_HOOK_ENDPOINT_URL" --set additionalEnv[0].value="custom_hook_endpoint_url"
```

## Post-Install

See Hasura's documentation for more information.  Link will be provided here in the near future.

## Parameters

| Name                                           | Description                                        | Value                                                                       |                |
| ---------------------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------- | -------------- |
| `global.domain`                                | Base domain for ingress host generation            | `""`                                                                        |                |
| `global.subDomain`                             | Toggle to use a subdomain in routing               | `true`                                                                      |                |
| `global.containerRegistry`                     | Docker registry for pulling images                 | `gcr.io/hasura-ee`                                                          |                |
| `global.certIssuer`                            | Certificate issuer for TLS                         | `letsencrypt-prod`                                                          |                |
| `global.uriScheme`                             | URI scheme (http or https)                         | `https`                                                                     |                |
| `labels.app`                                   | Application label for K8s resources                | `ddn-cli-api`                                                               |                |
| `additionalAnnotations`                        | Custom annotations like config checksums           | \`checksum/config: {{ include (print \$.Template.BasePath "/secret.yaml") . | sha256sum }}\` |
| `image.repository`                             | Container image name                               | `ddn-cli-api`                                                               |                |
| `image.tag`                                    | Container image version tag                        | `v0.1.1-a4f050b.1`                                                                    |                |
| `image.pullPolicy`                             | Image pull policy                                  | `IfNotPresent`                                                              |                |
| `replicas`                                     | Number of pod replicas                             | `"1"`                                                                       |                |
| `httpPort`                                     | HTTP port exposed by the container                 | `3000`                                                                      |                |
| `wsInactiveExpiryMins`                         | Inactive WebSocket timeout in minutes              | `"1"`                                                                       |                |
| `securityContext.runAsNonRoot`                 | Enforce non-root user execution                    | `true`                                                                      |                |
| `securityContext.runAsGroup`                   | Group ID for running container                     | `1000`                                                                      |                |
| `securityContext.runAsUser`                    | User ID for running container                      | `1000`                                                                      |                |
| `securityContext.fsGroup`                      | Filesystem group for mounted volumes               | `1000`                                                                      |                |
| `serviceAccount.enabled`                       | Toggle to use a Kubernetes service account         | `false`                                                                     |                |
| `serviceAccount.name`                          | Name of the service account to use                 | `""`                                                                        |                |
| `healthChecks.enabled`                         | Enable liveness and readiness probes               | `true`                                                                      |                |
| `healthChecks.livenessProbe`                   | Liveness probe config                              | `GET /health on port 3000`                                                  |                |
| `healthChecks.readinessProbe`                  | Readiness probe config                             | `GET /health on port 3000`                                                  |                |
| `resources.requests.cpu`                       | Minimum CPU resources requested                    | `200m`                                                                      |                |
| `resources.requests.memory`                    | Minimum memory requested                           | `500Mi`                                                                     |                |
| `resources.limits.cpu`                         | Maximum CPU limit                                  | `1`                                                                         |                |
| `resources.limits.memory`                      | Maximum memory limit                               | `1Gi`                                                                       |                |
| `ingress.enabled`                              | Enable ingress resource creation                   | `false`                                                                     |                |
| `ingress.ingressClassName`                     | Ingress class name (e.g., nginx)                   | `nginx`                                                                     |                |
| `ingress.hostName`                             | Hostname template for ingress                      | `{{ template "ddn-cli-api.domain" . }}`                                     |                |
| `ingress.additionalAnnotations`                | Extra annotations for ingress                      | `{{ template "ddn-cli-api.ingress.annotations" . }}`                        |                |
| `ingress.path`                                 | Ingress path                                       | `{{ template "ddn-cli-api.path" . }}`                                       |                |
| `ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT`         | Control Plane GraphQL API endpoint                 | e.g. `https://data.<domain>/v1/graphql`                                     |                |
| `ddnCliApiEnvVars.HASURA_DDN_CONSOLE_HOST`     | Hasura DDN Console Host                            | e.g. `https://console.<domain>`                                             |                |
