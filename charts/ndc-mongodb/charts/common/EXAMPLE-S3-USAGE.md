# S3 Sync Usage Example

This document shows how to add S3 configuration sync functionality to any connector chart using the common chart templates.

## Step 1: Add S3 ConfigMap Template

Create `templates/s3-sync-configmap.yaml`:

```yaml
{{- include "common.s3-sync-configmap" . }}
```

## Step 2: Update values.yaml

Add S3 configuration support to your `values.yaml`:

```yaml
# Connector Configuration
connectorConfig:
  enabled: false
  mountPath: "/etc/connector"
  
  # S3-based configuration (supports AWS S3, MinIO, S3-compatible storage)
  s3Config:
    enabled: false
    bucket: "my-config-bucket"
    region: "us-east-1"
    
    # AWS Credentials (not needed if using IRSA on EKS)
    useIRSA: false
    credentialsSecret: "aws-credentials"
    
    # S3 endpoint (optional - only needed for MinIO or S3-compatible storage)
    # Leave empty for AWS S3
    # Examples:
    #   MinIO: "http://minio.default.svc.cluster.local:9000"
    #   MinIO external: "https://minio.example.com"
    #   AWS S3: "" (empty - uses default AWS endpoint)
    endpoint: ""
    
    # S3 prefix to sync (everything under this prefix will be copied)
    # Examples:
    #   "" - sync entire bucket
    #   "configs/" - sync everything from configs/ folder
    #   "prod/connector-name/" - sync everything from prod/connector-name/ folder
    prefix: ""

# Init container configuration for S3 downloads
initContainers:
  s3ConfigSetup:
    image:
      repository: "gcr.io/hasura-ee/aws-cli"
      tag: "2.32.7"
      pullPolicy: "IfNotPresent"
```

## Step 3: Add Init Container

Add the S3 sync init container to your `values.yaml`:

```yaml
# Extra init containers - only for S3 downloads
extraInitContainers: |
  {{- if and .Values.connectorConfig.enabled .Values.connectorConfig.s3Config.enabled }}
  - name: setup-s3-config
    image: {{ .Values.initContainers.s3ConfigSetup.image.repository }}:{{ .Values.initContainers.s3ConfigSetup.image.tag }}
    imagePullPolicy: {{ .Values.initContainers.s3ConfigSetup.image.pullPolicy }}
    command:
    - sh
    - /scripts/s3-sync.sh
    env:
    {{- if not .Values.connectorConfig.s3Config.useIRSA }}
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: {{ .Values.connectorConfig.s3Config.credentialsSecret }}
          key: access-key-id
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: {{ .Values.connectorConfig.s3Config.credentialsSecret }}
          key: secret-access-key
    {{- end }}
    - name: AWS_DEFAULT_REGION
      value: {{ .Values.connectorConfig.s3Config.region | quote }}
    volumeMounts:
    - name: connector-config-dest
      mountPath: {{ .Values.connectorConfig.mountPath }}
    {{- include "common.s3-sync-volume-mount" . | nindent 4 }}
  {{- end }}
```

## Step 4: Add Volumes

Add the necessary volumes to your `values.yaml`:

```yaml
# Extra volumes for connector config
extraVolumes: |
  {{- if .Values.connectorConfig.enabled }}
  {{- if .Values.connectorConfig.s3Config.enabled }}
  {{- /* S3 mode: need emptyDir for downloads */}}
  - name: connector-config-dest
    emptyDir: {}
  {{- include "common.s3-sync-volume" . | nindent 2 }}
  {{- end }}
  {{- end }}

# Extra volume mounts for main container
extraVolumeMounts: |
  {{- if .Values.connectorConfig.enabled }}
  {{- if .Values.connectorConfig.s3Config.enabled }}
  {{- /* S3 mode: mount emptyDir */}}
  - name: connector-config-dest
    mountPath: {{ .Values.connectorConfig.mountPath }}
  {{- end }}
  {{- end }}
```

## Step 5: Set Environment Variable

Ensure your main container knows where to find the configuration:

```yaml
# Environment variables for main container
extraEnv: |
  {{- if .Values.connectorConfig.enabled }}
  - name: HASURA_CONFIGURATION_DIRECTORY
    value: {{ .Values.connectorConfig.mountPath }}
  {{- end }}
```

## Usage Examples

### AWS S3 with IRSA
```bash
helm install my-connector ./my-connector-chart \
  --set connectorConfig.enabled=true \
  --set connectorConfig.s3Config.enabled=true \
  --set connectorConfig.s3Config.useIRSA=true \
  --set connectorConfig.s3Config.bucket="my-config-bucket" \
  --set connectorConfig.s3Config.prefix="prod/my-connector/"
```

### MinIO
```bash
helm install my-connector ./my-connector-chart \
  --set connectorConfig.enabled=true \
  --set connectorConfig.s3Config.enabled=true \
  --set connectorConfig.s3Config.useIRSA=false \
  --set connectorConfig.s3Config.credentialsSecret="minio-credentials" \
  --set connectorConfig.s3Config.bucket="connector-configs" \
  --set connectorConfig.s3Config.endpoint="http://minio.default.svc.cluster.local:9000"
```

That's it! Your connector chart now supports S3-based configuration sync with AWS S3, MinIO, and other S3-compatible storage systems.
