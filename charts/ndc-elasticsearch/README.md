# Ndc-elasticsearch Helm Chart

This chart deploys the ndc-elasticsearch connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Connector Image

If you're running `docker compose build` within your Supergraph to build a custom connector image, or if you're using
the **git-sync** option with a Hasura-provided connector image, the base image used in both cases is: `ghcr.io/hasura/ndc-elasticsearch`

To determine the specific version of the image being used, check the `connector-metadata.yaml` file located under your Supergraph at: `app/connector/<connector-name>/.hasura-connector/connector-metadata.yaml`

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
  hasura-ddn/ndc-elasticsearch
```

## Enabling git-sync

Follow the pre-requisite [here](../../README.md#using-git-for-metadata-files) which has to be done once and deployed on the cluster.

Replace `<git_domain>`, `<org>` and `<repo>` placeholders in the below command to suit your git repository.

Additionally, ensure that `connectorEnvVars.configDirectory` is set to the correct path using the format shown below. Replace `<repo>` with the name of your Git repository, and `<connector-name>` with the name of your connector (found under `app/connector` in your Supergraph repo).  Ensure that you are not adding the `.git` suffix to `<repo>`.

Example: If your repo is `my-repo` and your connector is `my-connector`, the path should be:  `/work-dir/my-repo/app/connector/my-connector`

- Note: For `https` based checkout, a typical URL format for `initContainers.gitSync.repo` will be `https://<git_domain>/<org>/<repo>`.  For `ssh` based checkout, a typical URL format will be `git@<git_domain>:<org>/<repo>`

```bash
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-elasticsearch" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.ELASTICSEARCH_URL="elasticsearch_url" \
  --set connectorEnvVars.ELASTICSEARCH_USERNAME="elasticsearch_username" \
  --set connectorEnvVars.ELASTICSEARCH_PASSWORD="elasticsearch_password" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-elasticsearch
```

## Committing code to git

When you enable git-sync, the code will be fetched from the repository specified in `initContainers.gitSync.repo`, using the branch defined in `initContainers.gitSync.branch`.

## Credentials provider

If you have an auth service that can provide credentials to NDC Elasticsearch, you should make use of the credentials provider in the connector. The credentials provider works by requesting credentials from your auth service at the connector startup. The auth service should return a json response with the credentials present as a string in the root level credentials key and a 200 response code to be compliant with the credentials provider. Following is an example of a compliant response:

```json
{
  "credentials": "my-api-key"
}
```

To use credentials provider, set the following:

- `connectorEnvVars.ELASTICSEARCH_URL`
- `connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI`
- `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_KEY`
- `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM`

**If you downstream service does not return the expected response, you can additionally deploy an `auth-proxy` via [this](https://github.com/hasura/ddn-helm-charts/tree/main/charts/auth-proxy) Helm chart.**

## Credentials provider (sidecar deployment)

In cases where you do not want a standalone `auth-proxy` to be deployed via [this](https://github.com/hasura/ddn-helm-charts/tree/main/charts/auth-proxy) Helm chart, you have an option to enable the `auth-service`
to be run as a sidecar.  Below are examples how this would be accomplished:

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-elasticsearch" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.ELASTICSEARCH_URL="elasticsearch_url" \
  --set connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI="http://localhost:8081" \
  --set connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_KEY="elasticsearch_credentials_provider_key" \
  --set connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM="api-key|service-token|bearer-token" \
  --set authProxy.enabled=true \
  --set authProxy.image.repository="my_repo/auth-proxy" \
  --set authProxy.image.tag="my_custom_image_tag" \
  --set authProxy.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT="adfs_provider_endpoint" \
  --set authProxy.authProxyEnvVars.RESOURCE="resource" \
  --set authProxy.authProxyEnvVars.REGION="region" \
  hasura-ddn/ndc-elasticsearch | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-elasticsearch" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.ELASTICSEARCH_URL="elasticsearch_url" \
  --set connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI="http://localhost:8081" \
  --set connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_KEY="elasticsearch_credentials_provider_key" \
  --set connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM="api-key|service-token|bearer-token" \
  --set authProxy.enabled=true \
  --set authProxy.image.repository="my_repo/auth-proxy" \
  --set authProxy.image.tag="my_custom_image_tag" \
  --set authProxy.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT="adfs_provider_endpoint" \
  --set authProxy.authProxyEnvVars.RESOURCE="resource" \
  --set authProxy.authProxyEnvVars.REGION="region" \
  hasura-ddn/ndc-elasticsearch
```

## Private Registry Access via Image Pull Secrets (GCR Auth Example)

To pull container images from a private registry, such as when deploying connectors hosted in a restricted environment, you can configure an image pull secret using either a YAML override or Helm CLI flags.

- Note: The following example demonstrates authentication using a Google Container Registry (GCR) service account with _json_key authentication.

```yaml
global:
  # Set to true to deploy the image pull secret defined in the `secrets` section
  dataPlane:
    deployImagePullSecret: true

  # Reference the name of the image pull secret to be used
  # This name must remain consistent and match the one defined in the manifest
  imagePullSecrets:
    - hasura-image-pull

  # Enable creation of a service account and attach the image pull secret to it
  serviceAccount:
    enabled: true

secrets:
  imagePullSecret:
    auths:
      gcr.io:
        username: "_json_key"
        # Below content should be replaced with "company-sa.json" file content which is shared by the Hasura team, ensuring that it's indented correctly.
        password: |
          {}
        email: "support@hasura.io"
```

You can achieve the same configuration from the command line using the following steps:

- Save the service account key (JSON) into a file, e.g., `company-sa.json`
- Run Helm by adding the following flags:

```yaml
--set global.dataPlane.deployImagePullSecret=true \
--set global.imagePullSecrets[0]=hasura-image-pull \
--set global.serviceAccount.enabled=true \
--set secrets.imagePullSecret.auths.gcr\.io.username="_json_key" \
--set secrets.imagePullSecret.auths.gcr\.io.email="support@hasura.io" \
--set-file secrets.imagePullSecret.auths.gcr\.io.password=company-sa.json
```

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret.  This value comes from your Supergraph’s `.env` file and corresponds to the connector's `HASURA_SERVICE_TOKEN_SECRET` environment variable. (Optional)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_URL`    | The comma-separated list of Elasticsearch host addresses for connection (Required)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_USERNAME`               | The username for authenticating to the Elasticsearch cluster. Do not set if setting `authProxy.enabled` to `true` (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_PASSWORD`               | The password for the Elasticsearch user account. Do not set if setting `authProxy.enabled` to `true` (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_API_KEY`               | The Elasticsearch API key for authenticating to the Elasticsearch cluster. Do not set if setting `authProxy.enabled` to `true` (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CA_CERT_PATH`               | The path to the Certificate Authority (CA) certificate for verifying the Elasticsearch server's SSL certificate (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_INDEX_PATTERN`               | The pattern for matching Elasticsearch indices, potentially including wildcards, used by the connector (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_DEFAULT_RESULT_SIZE`               | The default query size when no limit is applied. Defaults to 10,000 (Optional)                                                                            | `""`                            |
| `connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI`               | The webhook URI for the auth service (Required when `authProxy.enabled` is `true`).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                          | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_KEY`               | This is the key for the credentials provider (Optional).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                      | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM`               | This is the security credential that is expected from the credential provider service. Could be `api-key`, `service-token` or `bearer-token` (Optional).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                          | `""`                            |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT`    | OTEL Exporter OTLP Endpoint (Optional)                                                                     | `"http://dp-otel-collector:4317"`                   |
| `connectorEnvVars.OTEL_SERVICE_NAME`              | OTEL Service Name (Optional)                                                                               | `ndc-elasticsearch`                  |

## auth-proxy ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `authProxy.enabled`                               | Enable auth-proxy running as a sidecar                                                                     | `false`                         |
| `authProxy.name`                                  | Name of service                                                                                            | `"auth-proxy"`                  |
| `authProxy.httpPort`                              | Port that application runs under                                                                           | `"8081"`                        |
| `authProxy.image.repository`                      | Image repository containing custom created auth-proxy                                                      | `""`                            |
| `authProxy.image.tag`                             | Image tag to use for custom created auth-proxy                                                             | `""`                            |
| `authProxy.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT` | ADFS Provider Endpoint (Required when `authProxy.enabled` is `true`)                                     | `""`                            |
| `authProxy.authProxyEnvVars.RESOURCE`             | Resource (Required when `authProxy.enabled` is `true`)                                                     | `""`                            |
| `authProxy.authProxyEnvVars.REGION`               | Region (Required when `authProxy.enabled` is `true`)                                                       | `""`                            |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `additionalAnnotations.checksum/config`           | Adds a checksum annotation for the `secret.yaml` file to force rollout on changes                          | `{{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}`                     |
| `additionalAnnotations.app.kubernetes.io/access-group` | Labels resources with an access group for organizational or access control purposes                   | `connector`                     |
| `networkPolicy.ingress.enabled`                   | Enables ingress network policy rules                                                                       | `true`                          |
| `networkPolicy.ingress.allowedApps`               | Specifies which applications (by label) are allowed ingress access                                         | `v3-engine`                     |
| `global.networkPolicy.enabled`                    | Enables or disables rendering of networkPolicy                                                             | `false`                         |
| `global.dataPlane.deployImagePullSecret`          | Whether to deploy the image pull secret defined in the `secrets` section                                   | `false`                         |
| `global.imagePullSecrets`                         | A list of image pull secret names to use. These must match what is defined in the `secrets` section        | `hasura-image-pull`             |
| `global.serviceAccount.enabled`                   | Enable creation of a Kubernetes service account and attach the image pull secret to it                     | `false`                         |
| `secrets.imagePullSecret.auths.gcr\.io.username`  | Username for authenticating to the container registry                                                      | `_json_key`                     |
| `secrets.imagePullSecret.auths.gcr\.io.password`  | Points to `company-sa.json` file (via `set-file`)                                                          | `company-sa.json`               |
| `secrets.imagePullSecret.auths.gcr\.io.email`     | Email associated with the registry authentication                                                          | `support@hasura.io`             |
| `image.repository`                                | Image repository containing custom created ndc-elasticsearch                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-elasticsearch                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
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
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |
| `initContainers.gitSync.secretName`               | Secret name for private key & known hosts (Used when initContainers.gitSync.enabled is set to true)        | `git-creds`                         |
| `serviceAccount.enabled`                          | Enable user of a service account for pod                                                                   | `false`                         |
| `serviceAccount.name`                             | Name for the service account                                                                               | `""`                            |