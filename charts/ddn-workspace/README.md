# Ddn-workspace Helm Chart

This chart deploys DDN Workspace (Native Runtime).

## Install Chart

See all [configuration](#parameters) below.

```bash
# EXAMPLES:

# helm template and apply manifests via kubectl (example)
helm template <release-name> \
  --set namespace="workspace" \
  --set global.domain="my-dp.domain.com" \
  --set global.tag="2.6.1" \
  --set consoleUrl="https://console.my-cp.domain.com" \
  --set secrets.password="argon2id_hashed_password" \
  hasura-ddn/ddn-workspace | kubectl apply -f-

# helm upgrade --install (pass configuration via command line)
helm upgrade --install <release-name> \
  --set namespace="workspace" \
  --set global.domain="my-dp.domain.com" \
  --set global.tag="2.6.1" \
  --set consoleUrl="https://console.my-cp.domain.com" \
  --set secrets.password="argon2id_hashed_password" \
  hasura-ddn/ddn-workspace
```

## Install Chart (With an overrides file)

Here's an example of an overrides file, targeting `2.6.1` image tag:

```yaml
global:
  certIssuer: "letsencrypt-prod"
  uriScheme: "https"
  domain: "hasura-dp.domain.com"
  namespace: "default"
  subDomain: true
  serviceAccount:
    enabled: true
  securityContext:
    disabled: false

  ingress:
    enabled: true
    ingressClassName: nginx
    additionalAnnotations: |
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-type: nlb

consoleUrl: "https://console.my-cp.domain.com"
skipTlsVerify: false

image:
  tag: "2.6.1"

secrets:
  # Hashed password for code server (Argon2id hash)
  # This was generated using a dummy password
  password: "$argon2id$v=19$m=16,t=2,p=1$TGY1cnNQblpGNmlCSnV4VQ$1/DpAKkaZhEtHDyVBqpF9A"

  imagePullSecret:
    auths:
      gcr.io:
        username: "_json_key"
        # Below content should be replaced with "company-sa.json" file content which is shared by the Hasura team, ensuring that it's indented correctly.
        password: |
          {}
        email: "support@hasura.io"
```

Install via the following command:

```bash
helm upgrade --install <release-name> \
  -f overrides.yaml \
  hasura-ddn/ddn-workspace
```

## Argo2id Password

The value being passed to `secrets.password` needs to be an `Argo2id` hashed password.  You can use a tool like [this](https://argon2.online/) to generate the appropriate hash from a given password.
When you generate a password, make sure you choose `Argon2id` as the mode/variant (This is the recommended approach per [RFC 9106](https://datatracker.ietf.org/doc/html/rfc9106)).

You can also use [this](https://github.com/hasura/ddn-helm-charts/tree/main/scripts/argon2id.py) Python script provided that you installed the `argon2-cffi` package via `pip install argon2-cffi`.

Note that when you pass the password via `--set`, you will need to escape `$` as well as `,` that are contained within the password.  If you are using an overrides file, you do not need to escape.

## Image pull secret

The DDN Workspace Helm chart is configured by default to fetch from Hasura's own private registry.  You will need to obtain an image pull secret in order to pull from this registry or otherwise
contact the Hasura engineering team in order to obtain alternate methods for fetching the image.

## Parameters

| Name                                              | Description                                                                                                | Value                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `global.domain`                                   | Base domain for DDN Workspace                                                                              | `""`                            |
| `global.subDomain`                                | Use a subdomain for DDN Workspace                                                                          | `true`                          |
| `global.certIssuer`                               | Cert issuer to use for ingress                                                                             | `letsencrypt-prod`              |
| `global.uriScheme`                                | URI Scheme for DDN Workspace                                                                               | `https`                         |
| `global.containerRegistry`                        | Container registry to pull image from                                                                      | `gcr.io/hasura-ee`              |
| `global.persistence.enabled`                      | Create a PVC for persisting `/workspace` directory within the DDN Workspace                                | `true`                          |
| `global.serviceCatalog`                           | Defines outgoing (egress) to specific pods based on labels                                                 | `[{'name': 'data', 'port': 8080}, {'name': 'ddn-cps-engine', 'port': 3000}]` |
| `global.serviceAccount.enabled`                   | Create SA (hasura-image-pull)                                                                              | `true`                          |
| `global.routes.enabled`                           | Enable routes (For OpenShift)                                                                              | `false`                         | 
| `additionalLabels.group`                          | Assigns given value to label group                                                                         | `ddn-workspace`                 |
| `networkPolicy.ingress.enabled`                   | Allow or disallow incoming network traffic                                                                 | `true`                          |
| `networkPolicy.egress.enabled`                    | Alow or disallow egress network traffic                                                                    | `true`                          |
| `networkPolicy.egress.allowedApps`                | List of allow apps for egress                                                                              | `['data', 'ddn-cps-engine']`    |
| `useReleaseName`                                  | Use Release Name                                                                                           | `true`                          |
| `image.repository`                                | Image name                                                                                                 | `ddn-native-workspace`          |
| `image.tag`                                       | Image tag                                                                                                  | `""`                            |
| `replicas`                                        | Replica count                                                                                              | `1`                             |
| `httpPort`                                        | HTTP port which service run on                                                                             | `8123`                          |
| `setControlPlaneUrls`                             | Sets necessary Control Plane URLs                                                                          | `true`                          |
| `persistence.enabled`                             | Create a PVC for persisting `/workspace` directory within the DDN Workspace                                | `true`                          |
| `persistence.size`                                | PVC size                                                                                                   | `10Gi`                          |
| `healthChecks.enabled`                            | Enable Health checks                                                                                       | `true`                          |
| `healthChecks.livenessProbe`                      | Health check liveness probe                                                                                | `httpGet:\n  path: /healthz\n  port: 8123\n` |
| `healthChecks.readinessProbe`                     | Health check readiness probe                                                                               | `httpGet:\n  path: /healthz\n  port: 8123\n` |
| `securityContext.runAsUser`                       | Security context runAsUser                                                                                 | `10001`                         |
| `securityContext.fsGroup`                         | Security context file system group ID                                                                      | `10001`                         |
| `securityContext.runAsNonRoot`                    | Security context runAsNonRoot                                                                              | `true`                          |
| `resources.requests.cpu`                          | CPU requested for the container                                                                            | `500m`                          |
| `resources.requests.memory`                       | Memory requested for the container                                                                         | `2048Mi`                        |
| `resources.limits.memory`                         | Maximum memory allowed for the container                                                                   | `2048Mi`                        |
| `hostAliases[0].ip`                               | IP address to alias in `/etc/hosts`                                                                        | `"127.0.0.1"`                   |
| `hostAliases[0].hostnames[0]`                     | Hostname mapped to the alias IP                                                                            | `"local.hasura.dev"`            |
| `dataHost`                                        | Host URL for the data service                                                                              | `"http://data:8080"`            |
| `ddnCpsEngineHost`                                | Host URL for the CPS engine                                                                                | `"http://ddn-cps-engine:3000"`  |
| `consoleUrl`                                      | DDN Console URL (Uses FQDN, prefixed with scheme)                                                          | `""`                            |
| `skipTlsVerify`                                   | Whether to skip TLS verification                                                                           | `false`                         |
| `secrets.password`                                | DDN Workspace password (Argon2id hash)                                                                     | `""`                            |
| `ingress.enabled`                                 | Enable or disable creation of ingress                                                                      | `true`                          |
| `ingress.ingressClassName`                        | Ingress class name                                                                                         | `nginx`                         |
| `ingress.hostName`                                | Ingress override hostname                                                                                  | `""`                            |
| `ingress.additionalAnnotations`                   | Ingress additional annotations                                                                             | `""`                            |
| `ingress.path`                                    | Ingress override path                                                                                      | `""`                            |
| `routes.enabled`                                  | Enable routes (For OpenShift)                                                                              | `false`                         |      
