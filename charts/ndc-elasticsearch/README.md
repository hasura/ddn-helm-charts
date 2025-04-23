# Ndc-elasticsearch Helm Chart

This chart deploys the ndc-elasticsearch connector. Refer to the pre-requisites section [here](../../README.md#get-started)

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

Replace `git_domain`, `org` and `repo` placeholders in the below command to suit your git repository.

Additionally, ensure that `connectorEnvVars.configDirectory` is set to the given path below, providing that you are also replacing `repo` and `connector-name` placeholders within it.  For clarity, `connector-name` is the name that was given to your connector (ie. Check `app/connector` under your Supergraph) and `repo` is appended with `.git`.  An example of a value for `connectorEnvVars.configDirectory` would be: `/work-dir/mycode.git/app/connector/myelasticsearch`.

Note: For `https` based checkout, a typical URL format for `initContainers.gitSync.repo` will be `https://<git_domain>/<org>/<repo>`.  For `ssh` based checkout, a typical URL format will be `git@<git_domain>:<org>/<repo>`

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

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret (Optional)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_URL`    | The comma-separated list of Elasticsearch host addresses for connection (Required)                                                                     | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_USERNAME`               | The username for authenticating to the Elasticsearch cluster (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_PASSWORD`               | The password for the Elasticsearch user account (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_API_KEY`               | The Elasticsearch API key for authenticating to the Elasticsearch cluster (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CA_CERT_PATH`               | The path to the Certificate Authority (CA) certificate for verifying the Elasticsearch server's SSL certificate (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_INDEX_PATTERN`               | The pattern for matching Elasticsearch indices, potentially including wildcards, used by the connector (Optional)                                                                            | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_DEFAULT_RESULT_SIZE`               | The default query size when no limit is applied. Defaults to 10,000 (Optional)                                                                            | `""`                            |
| `connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI`               | The webhook URI for the auth service (Optional).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                          | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_KEY`               | This is the key for the credentials provider (Optional).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                      | `""`                            |
| `connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM`               | This is the security credential that is expected from the credential provider service. Could be `api-key` or `service-token` (Optional).  See [this](https://github.com/hasura/ndc-elasticsearch/blob/main/docs/auth.md#credentials-provider) for more information                                                                          | `""`                            |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT`    | OTEL Exporter OTLP Endpoint (Optional)                                                                     | `"http://dp-otel-collector:4317"`                   |
| `connectorEnvVars.OTEL_SERVICE_NAME`              | OTEL Service Name (Optional)                                                                               | `ndc-elasticsearch`                  |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
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