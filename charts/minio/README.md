# MinIO Helm Chart

> **Deprecated (v0.2.0):** This standalone MinIO chart is deprecated and will no longer be maintained. Starting with
> DDN Self-Hosted release **2.7.14**, MinIO is managed as a subchart of the `v3-control-plane` Helm chart with native
> secret support via the `nativeSecret` configuration. New installations should use the `v3-control-plane` chart
> directly.

## Migrating to v3-control-plane (2.7.14+)

If you previously installed MinIO using this standalone chart, you can migrate to the `v3-control-plane` chart by
transferring Helm resource ownership. This avoids downtime by re-using the existing MinIO resources.

**1. Re-annotate existing MinIO resources** to transfer ownership to the control plane release:

```bash
# Replace <namespace> and <cp-release-name> with your values
for resource in $(kubectl get all,secret,configmap,serviceaccount,ingress,pvc,job -n <namespace> \
  -o json | jq -r '.items[] | select(.metadata.annotations["meta.helm.sh/release-name"] == "minio") | "\(.kind)/\(.metadata.name)"'); do
  kubectl annotate "$resource" -n <namespace> \
    meta.helm.sh/release-name=<cp-release-name> \
    meta.helm.sh/release-namespace=<namespace> \
    --overwrite
done
```

**2. Remove the old Helm release tracking** (without deleting the actual resources):

```bash
# Do NOT use "helm uninstall minio" — that would delete the resources.
# Instead, remove Helm's internal release secret directly:
kubectl delete secret -n <namespace> -l owner=helm,name=minio
```

**3. Install the control plane chart** with `nativeSecret` enabled in your overrides:

```yaml
# In your v3-control-plane overrides file
minio:
  nativeSecret:
    enabled: true
    name: "minio"        # name of your existing Secret with config.env
    key: "config.env"
```

```bash
helm upgrade --install <cp-release-name> -n <namespace> \
  -f v3-control-plane-overrides.yaml \
  v3-control-plane-2.7.14.tgz
```

---

## Legacy Documentation (v0.2.0)

A standalone MinIO chart for Hasura DDN self-hosted deployments. This chart is customized to work with the "native"
external secrets provider approach, where credentials are managed via Kubernetes-native secret management tools such as
Sealed Secrets, SOPS, or plain Kubernetes Secrets — no external vault infrastructure required.

It deploys a single-node MinIO server with a post-install job that creates the default bucket and (optionally) a console
user.

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
