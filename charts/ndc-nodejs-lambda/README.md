# Ndc-nodejs-lambda Helm Chart

This chart deploys the ndc-nodejs-lambda connector. Refer to the pre-requisites section [here](../../README.md#get-started)

## Connector Image

If you're running `docker compose build` within your Supergraph to build a custom connector image, or if you're using
the **git-sync** option with a Hasura-provided connector image, the base image used in both cases is: `ghcr.io/hasura/ndc-nodejs-lambda`

To determine the specific version of the image being used, check the `connector-metadata.yaml` file located under your Supergraph at: `app/connector/<connector-name>/.hasura-connector/connector-metadata.yaml`

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-nodejs-lambda" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-nodejs-lambda | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  --set image.repository="my_repo/ndc-nodejs-lambda" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  hasura-ddn/ndc-nodejs-lambda
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
  --set image.repository="my_repo/ndc-nodejs-lambda" \
  --set image.tag="my_custom_image_tag" \
  --set connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET="token" \
  --set initContainers.gitSync.enabled="true" \
  --set initContainers.gitSync.repo="git@<git_domain>:<org>/<repo>" \
  --set initContainers.gitSync.branch="main" \
  --set connectorEnvVars.configDirectory="/work-dir/<repo>/app/connector/<connector-name>" \
  hasura-ddn/ndc-nodejs-lambda
```

## Committing code to git

When git-sync is enabled, the application code is fetched from the Git repository defined in `initContainers.gitSync.repo`, using the branch specified in `initContainers.gitSync.branch`.

By **default**, the setup expects the `node_modules` directory (produced by running `npm ci`) to be committed and present in the Git repository.

If you prefer **not to commit** the `node_modules` directory to your repository, you can configure the system to use pre-packaged dependencies from a Docker image instead. To do this:

- Build a custom Docker image that includes the `node_modules` directory.  Use the `Dockerfile` which is included in your connector's `.hasura-connector` folder to build the image.
  - This directory should be located at `/functions` inside the image.
- Install your Helm chart with `--set initContainers.gitSync.depsPackaged=false`
  - This tells the system to use the pre-packaged dependencies instead of expecting them in the Git repo.

## Connector ENV Inputs

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `connectorEnvVars.HASURA_SERVICE_TOKEN_SECRET`    | Hasura Service Token Secret.  This value comes from your Supergraph’s `.env` file and corresponds to the connector's `HASURA_SERVICE_TOKEN_SECRET` environment variable. (Optional)                                                                     | `""`                            |
| `connectorEnvVars.configDirectory`                | Connector config directory (See [Enabling git-sync](README.md#enabling-git-sync) when initContainers.gitSync.enabled is set to true) (Optional) | `""`                   |
| `connectorEnvVars.OTEL_EXPORTER_OTLP_ENDPOINT`    | OTEL Exporter OTLP Endpoint (Optional)                                                                     | `"http://dp-otel-collector:4317"`                   |
| `connectorEnvVars.OTEL_SERVICE_NAME`              | OTEL Service Name (Optional)                                                                               | `ndc-nodejs-lambda`                  |

## Additional Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `namespace`                                       | Namespace to deploy to                                                                                     | `"default"`                     |
| `image.repository`                                | Image repository containing custom created ndc-nodejs-lambda                                                    | `""`                            |
| `image.tag`                                       | Image tag to use for custom created ndc-nodejs-lambda                                                           | `""`                            |
| `image.pullPolicy`                                | Image pull policy                                                                                          | `Always`                        |
| `resources`                                       | Resource requests and limits of ndc-nodejs-lambda container                                                     | `{}`                            |
| `env`                                             | Env variable section for ndc-nodejs-lambda                                                                      | `[]`                            |
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
| `initContainers.gitSync.enabled`                  | Enable reading connector config files from a git repository                                                | `false`                             |
| `initContainers.gitSync.repo`                     | Git repository to read from (Used when initContainers.gitSync.enabled is set to true)                      | `git@github.com:<org>/<repo>`       |
| `initContainers.gitSync.branch`                   | Branch to read from (Used when initContainers.gitSync.enabled is set to true)                              | `main`                              |
| `initContainers.gitSync.secretName`               | Secret name for private key & known hosts (Used when initContainers.gitSync.enabled is set to true)        | `git-creds`                         |
| `initContainers.gitSync.depsPackaged`             | Whether node_modules was packaged into git repo (Used when initContainers.gitSync.enabled is set to true)  | `true`                              |