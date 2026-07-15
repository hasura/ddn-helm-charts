# MinIO Helm Chart

A standalone MinIO chart for Hasura DDN self-hosted deployments. This chart deploys a single-node MinIO server with a
post-install job that creates the default bucket and (optionally) a console user.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.x
- A pre-existing Kubernetes Secret containing MinIO credentials (see [Creating the Secret](#creating-the-secret))

## Creating the Secret

MinIO credentials are supplied via a pre-existing Kubernetes Secret. The Secret must contain a single key (default:
`config.env`) whose value is a newline-delimited list of `KEY=VALUE` pairs:

```bash
kubectl create secret generic minio \
  --from-literal=config.env="$(cat <<'EOF'
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your-secure-password
EOF
)" \
  -n <namespace>
```

Or as a YAML manifest:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio
type: Opaque
stringData:
  config.env: |
    MINIO_ROOT_USER=minioadmin
    MINIO_ROOT_PASSWORD=your-secure-password
```

The Secret name and key are configurable via `existingSecret.name` and `existingSecret.key` in your overrides.

## Install Chart

```bash
helm upgrade --install minio \
  -f minio-overrides.yaml \
  hasura-ddn/minio \
  -n <namespace>
```

## Sample Overrides File

```yaml
image:
  repository: gcr.io/hasura-ee/minio

mcImage:
  repository: gcr.io/hasura-ee/mc

existingSecret:
  name: "minio"
  key: "config.env"

securityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  fsGroupChangePolicy: OnRootMismatch

imagePullSecrets:
  - name: hasura-image-pull
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | MinIO server image repository | `gcr.io/hasura-ee/minio` |
| `image.tag` | MinIO server image tag | `RELEASE.2025-03-12T18-04-18Z` |
| `mcImage.repository` | MinIO mc (client) image repository | `gcr.io/hasura-ee/mc` |
| `mcImage.tag` | MinIO mc image tag | `RELEASE.2025-03-12T17-29-24Z` |
| `imagePullSecrets` | Registry pull secrets | `[{name: hasura-image-pull}]` |
| `existingSecret.name` | Name of the K8s Secret with MinIO credentials | `minio` |
| `existingSecret.key` | Key within the Secret containing `KEY=VALUE` config | `config.env` |
| `consoleUser.accessKey` | Console user access key (optional) | _unset_ |
| `consoleUser.secretKey` | Console user secret key (optional) | _unset_ |
| `consoleUser.policy` | Console user policy (optional) | `consoleAdmin` |
| `serviceAccount.name` | Service account name | `minio-sa` |
| `persistence.size` | PVC size | `20Gi` |
| `persistence.accessMode` | PVC access mode | `ReadWriteOnce` |
| `persistence.storageClass` | Storage class (omit for default) | _unset_ |
| `bucket.name` | Bucket created by post-install job | `v3-metadata-blob-store` |
| `bucket.policy` | Bucket policy | `none` |
| `securityContext.runAsUser` | Pod security context UID | `1000` |
| `securityContext.runAsGroup` | Pod security context GID | `1000` |
| `securityContext.fsGroup` | Pod filesystem group | `1000` |
| `resources` | Server container resource requests/limits | `{requests: {memory: 200Mi}}` |
| `jobResources` | Post-install job resource requests/limits | `{requests: {memory: 128Mi}}` |
