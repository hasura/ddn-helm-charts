# Engine-plugin-caching Helm Chart

This chart deploys Engine Plugin Caching.

## Rate Limit config

Check out the following [repo](https://github.com/hasura/engine-plugin-caching/tree/main?tab=readme-ov-file#configuration) which includes information about what configuration
parameters are available.  These parameters will be included within the config.js (ie.  The section which you define under `configs.enginePluginCachingConfig.otherConfig`).

Furthermore, check out our [public doc](https://hasura.io/docs/3.0/plugins/caching/how-to/) related to configuration of the caching plugin.

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="default" \
  -f caching-overrides.yaml \
  hasura-ddn/engine-plugin-caching | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="default" \
  -f caching-overrides.yaml \
  hasura-ddn/engine-plugin-caching
```

## Install Chart (With an overrides file)

**NOTE: If you do not specify an overrides file, Redis will be deployed into the cluster and a default config.js config will be provided**

Here's an example of a `caching-overrides.yaml` file.  Here are the key points:

1. We are setting `randomtoken` as the Auth Token.  This is used for communication between the `v3-engine` and the plugin
2. We are not deploying built-in Redis.  We are setting a custom `redisUrl` which points to an externally managed Redis
3. We want to cache the following query, for 600 seconds:

```yaml
query sample_coupons {
  coupons {
    amount
    code
    createdAt
    expirationDate
    id
    percentOrValue
    updatedAt
    userId
  }
}
```

```yaml caching-overrides.yaml
configs:
  deployRedis: false
  enginePluginCachingConfig:
    redisUrl: ""
    otherConfig: |
      headers: { "hasura-m-auth": "randomtoken" },

      cache_key: {
        rawRequest: {
          query: true,
          operationName: false,
          variables: true,
        },
        session: true,
        headers: [
          // "X-Hasura-Unique-Cache-Key",
        ],
      },

      queries_to_cache: [
        { query: "query sample_coupons { coupons { amount code createdAt expirationDate id percentOrValue updatedAt userId }}", time_to_live: 600 }
      ],
      otel_headers: {},
```

Install via the following command:

```bash
helm upgrade --install <release-name> \
  -f caching-overrides.yaml \
  hasura-ddn/engine-plugin-caching
```

## Image pull secret

The Engine Plugin Caching Helm chart is configured by default to fetch from Hasura's own private registry.  You will need to obtain an image pull secret in order to pull from this registry or otherwise contact the Hasura engineering team in order to obtain alternate methods for fetching the image.

Note that you will be installing this Helm Chart within the Data Plane.  If you installed the Data Plane and you fetched images from Hasura's private registry, an `hasura-image-pull` secret was already created.  This deployment will be referencing this image pull secret.

## Parameters

| Name                                              | Description                                                       | Value                                       |
| ------------------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------- |
| `global.serviceAccount.enabled`                   | Whether to create and use a Kubernetes service account            | `true`                                      |
| `global.imagePullSecrets`                         | List of image pull secrets for private registries                 | `["hasura-image-pull"]`                     |
| `useReleaseName`                                  | Whether to use the Helm release name as a base for resource names | `true`                                      |
| `image.repository`                                | Docker image repository for the rate-limit plugin                 | `gcr.io/hasura-ee/engine-plugin-caching` |
| `image.tag`                                       | Docker image tag/version                                          | `v1.0.0`                                    |
| `replicas`                                        | Number of pod replicas                                            | `"1"`                                       |
| `httpPort`                                        | Port on which the container listens                               | `8787`                                      |
| `healthChecks.enabled`                            | Enable liveness and readiness probes                              | `true`                                      |
| `healthChecks.livenessProbe`                      | YAML definition of liveness probe                                 | Probe block                                 |
| `healthChecks.readinessProbe`                     | YAML definition of readiness probe                                | Probe block                                 |
| `securityContext.runAsUser`                       | UID to run the container as                                       | `10001`                                     |
| `securityContext.fsGroup`                         | Group ID for shared file system access                            | `10001`                                     |
| `securityContext.runAsNonRoot`                    | Require the container to run as a non-root user                   | `true`                                      |
| `extraVolumes`                                    | Extra volumes to mount, supports ConfigMaps and Secrets           | Volume block                                |
| `extraVolumeMounts`                               | Volume mounts for above volumes                                   | VolumeMount block                           |
| `resources`                                       | Resource requests and limits for the container                    | Resource block                              |
| `configs.deployRedis`                             | Whether to deploy Redis                                           | `true`                                      |
| `configs.enginePluginCachingConfig.redisUrl`      | Redis connection URL override (if not templated)                  | `""`                                        |
| `configs.enginePluginCachingConfig.otherConfig`   | JSON structure defining rate-limiting behavior.                   | JSON block                                  |
| `env`                                             | List of environment variables to inject into the container        | Env block                                   |
