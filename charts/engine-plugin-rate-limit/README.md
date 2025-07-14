# Engine-plugin-rate-limit Helm Chart

This chart deploys Engine Plugin Rate Limit.

## Rate Limit config

Check out the following [repo](https://github.com/hasura/engine-plugin-rate-limit/tree/main?tab=readme-ov-file#configuration) which includes information about what configuration
parameters are available.  These parameters will be included within the rate-limit.json (ie.  The section which you define under `configs.enginePluginRateLimitConfig.otherConfig`).

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  hasura-ddn/engine-plugin-rate-limit | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  hasura-ddn/engine-plugin-rate-limit
```

## Install Chart (With an overrides file)

**NOTE: If you do not specify an overrides file, Redis will be deployed into the cluster and a default rate-limit.json config will be provided**

Here's an example of an overrides file.  Here are the key points:

1. We are setting `randomtoken` as the Auth Token.  This is used for communication between the `v3-engine` and the plugin
2. We are not deploying built-in Redis
3. We are setting a custom `redisUrl` which points to an externally managed Redis
4. A custom `rate_limit` config is provided

```yaml
secrets:
  enginePluginRateLimitAuthToken: "randomtoken"

configs:
  deployRedis: false
  enginePluginRateLimitConfig:
    redisUrl: "redis://external-url:6379"
    otherConfig: |
      "rate_limit": {
        "default_limit": 10,
        "time_window": 60,
        "excluded_roles": [],
        "key_config": {
          "from_headers": [],
          "from_session_variables": [],
          "from_role": true
        },
        "unavailable_behavior": {
          "fallback_mode": "deny"
        },
        "role_based_limits": [
          {
            "role": "user",
            "limit": 11
          },
          {
            "role": "admin",
            "limit": 10
         }
       ]
      }
```

Install via the following command:

```bash
helm upgrade --install <release-name> \
  -f overrides.yaml \
  hasura-ddn/engine-plugin-rate-limit
```

## Image pull secret

The Engine Plugin Rate Limit Helm chart is configured by default to fetch from Hasura's own private registry.  You will need to obtain an image pull secret in order to pull from this registry or otherwise contact the Hasura engineering team in order to obtain alternate methods for fetching the image.

Note that you will be installing this Helm Chart within the Data Plane.  If you installed the Data Plane and you fetched images from Hasura's private registry, an `hasura-image-pull` secret was already created.  This deployment will be referencing this image pull secret.

## Parameters

| Name                                              | Description                                                       | Value                                       |
| ------------------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------- |
| `global.serviceAccount.enabled`                   | Whether to create and use a Kubernetes service account            | `true`                                      |
| `global.imagePullSecrets`                         | List of image pull secrets for private registries                 | `["hasura-image-pull"]`                     |
| `useReleaseName`                                  | Whether to use the Helm release name as a base for resource names | `true`                                      |
| `image.repository`                                | Docker image repository for the rate-limit plugin                 | `gcr.io/hasura-ee/engine-plugin-rate-limit` |
| `image.tag`                                       | Docker image tag/version                                          | `v1.0.0`                                    |
| `replicas`                                        | Number of pod replicas                                            | `"1"`                                       |
| `httpPort`                                        | Port on which the container listens                               | `3000`                                      |
| `healthChecks.enabled`                            | Enable liveness and readiness probes                              | `true`                                      |
| `healthChecks.livenessProbe`                      | YAML definition of liveness probe                                 | Probe block                                 |
| `healthChecks.readinessProbe`                     | YAML definition of readiness probe                                | Probe block                                 |
| `securityContext.runAsUser`                       | UID to run the container as                                       | `10001`                                     |
| `securityContext.fsGroup`                         | Group ID for shared file system access                            | `10001`                                     |
| `securityContext.runAsNonRoot`                    | Require the container to run as a non-root user                   | `true`                                      |
| `extraVolumes`                                    | Extra volumes to mount, supports ConfigMaps and Secrets           | Volume block                                |
| `extraVolumeMounts`                               | Volume mounts for above volumes                                   | VolumeMount block                           |
| `resources`                                       | Resource requests and limits for the container                    | Resource block                              |
| `secrets.enginePluginRateLimitAuthToken`          | Token used for authenticating the rate-limit plugin               | `"randomtoken"`                             |
| `configs.deployRedis`                             | Whether to deploy Redis                                           | `true`                                      |
| `configs.enginePluginRateLimitConfig.redisUrl`    | Redis connection URL override (if not templated)                  | `""`                                        |
| `configs.enginePluginRateLimitConfig.otherConfig` | JSON structure defining rate-limiting behavior.                   | JSON block                                  |
| `env`                                             | List of environment variables to inject into the container        | Env block                                   |
