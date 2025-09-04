# DDN Workspace with Auth Proxy Sidecar Integration

This document explains the sidecar implementation of auth-proxy within the ddn-workspace Helm chart.

## Architecture Overview

The auth-proxy runs as a **sidecar container** within the same pod as the workspace, providing authentication and workspace access control.

```
┌─────────────────────────────────────────────────────────────┐
│                        Kubernetes Pod                       │
│  ┌─────────────────┐              ┌─────────────────────┐   │
│  │   Auth Proxy    │   localhost  │    Workspace        │   │
│  │   (Port 8080)   │ ──────────── │   (Port 8123)       │   │
│  │                 │              │                     │   │
│  │ • Authentication │              │ • Code Server       │   │
│  │ • Workspace     │              │ • DDN Tools         │   │
│  │   Access Control│              │ • Project Files     │   │
│  └─────────────────┘              └─────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           │
                    ┌─────────────┐
                    │   Service   │
                    │ Port 8080   │ ← Ingress routes here
                    └─────────────┘
```

## Key Benefits

✅ **Security**: Workspace is not directly accessible from outside the pod  
✅ **Performance**: Localhost communication between auth-proxy and workspace  
✅ **Simplicity**: Single pod deployment with shared volumes  
✅ **Resource Efficiency**: Shared network namespace and storage  
✅ **Scalability**: Pod-level scaling includes both containers  

## Configuration

### Enable Auth Proxy Sidecar

```yaml
# Enable no-auth mode (required)
noAuth:
  enabled: true

# Enable workspace auth-proxy sidecar
workspaceAuthProxy:
  enabled: true
```

### Routing Modes

#### Subdomain Routing
```yaml
global:
  domain: "hasura.io"
  subDomain: true

# Results in: workspace-name.hasura.io → auth-proxy:8080 → workspace:8123
```

#### Path-Based Routing
```yaml
global:
  domain: "hasura.io"
  subDomain: false

# Results in: hasura.io/workspace-name/ → auth-proxy:8080 → workspace:8123
```

## Implementation Details

### Sidecar Container Configuration

The auth-proxy is added as an `extraContainer` in the deployment:

```yaml
extraContainers: |
  {{- if include "ddn-workspace.workspaceAuthProxy.enabled" . }}
  - name: auth-proxy
    image: "{{ .Values.global.containerRegistry }}/{{ .Values.workspaceAuthProxy.image.repository }}:{{ .Values.workspaceAuthProxy.image.tag }}"
    ports:
      - name: auth-http
        containerPort: 8080
      - name: auth-admin
        containerPort: 9901
    # ... environment variables and volume mounts
  {{- end }}
```

### Service Configuration

The main service exposes both auth-proxy and workspace ports:

```yaml
servicePorts: |
  {{- if include "ddn-workspace.workspaceAuthProxy.enabled" . }}
  - port: 8080          # Auth proxy HTTP port
    targetPort: auth-http
    name: auth-http
  - port: 9901          # Auth proxy admin port
    targetPort: auth-admin
    name: auth-admin
  {{- end }}
```

### Ingress Configuration

Traffic is routed to the auth-proxy port (8080):

```yaml
backend:
  service:
    name: {{ include "common.name" . }}
    port:
      number: 8080  # Routes to auth-proxy, not workspace
```

### Localhost Communication

The auth-proxy is configured to route to the workspace via localhost:

```yaml
# In Envoy configuration
- name: workspace_service
  type: STATIC
  endpoints:
    - socket_address:
        address: "127.0.0.1"  # Same pod
        port_value: 8123      # Workspace port
```

## Deployment Example

```bash
helm install my-workspace . \
  --set noAuth.enabled=true \
  --set workspaceAuthProxy.enabled=true \
  --set global.domain="example.com" \
  --set global.subDomain=true
```

## Request Flow

1. **External Request** → `workspace.example.com`
2. **Ingress** → Routes to service port 8080
3. **Auth Proxy Container** → Validates JWT and workspace access
4. **Localhost Proxy** → `127.0.0.1:8123` (workspace container)
5. **Workspace Container** → Serves the application

## Security Model

### Authentication
- Cookie-based session management
- GraphQL-based workspace validation

### Authorization
- Workspace access validated through GraphQL queries
- User must have access to specific workspace

### Network Security
- Workspace not directly accessible from outside pod
- All external traffic goes through auth-proxy
- Internal communication via localhost

## Monitoring and Debugging

### Health Checks
```bash
# Check auth-proxy health
kubectl exec -it pod-name -c auth-proxy -- curl localhost:9901/ready

# Check workspace health
kubectl exec -it pod-name -c workspace-name -- curl localhost:8123/healthz
```

### Logs
```bash
# Auth-proxy logs
kubectl logs pod-name -c auth-proxy

# Workspace logs
kubectl logs pod-name -c workspace-name
```

### Envoy Admin Interface
```bash
# Port forward admin interface
kubectl port-forward pod-name 9901:9901

# Check clusters
curl http://localhost:9901/clusters

# Check configuration
curl http://localhost:9901/config_dump
```

## Troubleshooting

### Common Issues

1. **Auth-proxy not starting**
   - Verify ConfigMap is mounted correctly
   - Check resource limits
   - Verify DATA_HOST and DATA_PORT environment variables

2. **Workspace access denied**
   - Check workspace name matches deployment name
   - Verify GraphQL data service is accessible
   - Check DATA_HOST configuration

4. **Service connectivity issues**
   - Ensure both containers are in same pod
   - Check localhost communication (127.0.0.1:8123)
   - Verify service port configuration

### Debug Commands

```bash
# Test auth-proxy directly
kubectl exec -it pod-name -c auth-proxy -- curl -v localhost:8080/

# Test workspace directly
kubectl exec -it pod-name -c workspace-name -- curl -v localhost:8123/

# Check Envoy configuration
kubectl exec -it pod-name -c auth-proxy -- cat /etc/envoy/envoy.yaml
```

## Migration from Separate Deployment

If migrating from a separate auth-proxy deployment:

1. Remove separate auth-proxy deployment
2. Enable sidecar mode: `workspaceAuthProxy.enabled: true`
3. Update ingress to point to main service
4. Remove separate auth-proxy service
5. Test localhost communication

## Limitations

- Single workspace per pod (no multi-tenancy)
- Requires `noAuth.enabled: true`
- Auth-proxy and workspace share resource limits
- Both containers restart together

## Performance Considerations

- Localhost communication is very fast
- Shared memory and network namespace
- Resource requests should account for both containers
- Consider CPU and memory limits for both containers

## Security Best Practices

1. Always use HTTPS in production
2. Set appropriate JWT expiration times
3. Use secure cookie settings
4. Implement proper RBAC for workspace access
5. Monitor auth-proxy logs for security events
6. Regularly rotate JWT signing keys

## Auth Service URL Configuration

The auth service URL is automatically configured based on the routing mode and made available to both the auth-proxy and workspace containers.

### Environment Variables

The following environment variables are automatically set:

**Auth Proxy Container:**
- `AUTH_SERVICE_URL`: URL of the authentication service

**Workspace Container:**
- `HASURA_DDN_AUTH_SERVICE_URL`: URL of the authentication service (for UI)

### URL Generation Logic

The auth service URL is generated based on the routing mode:

#### Subdomain Mode (`global.subDomain: true`)
```yaml
global:
  domain: "example.com"
  subDomain: true
  uriScheme: "https"

# Results in: AUTH_SERVICE_URL=https://auth.example.com
```

#### Path Mode (`global.subDomain: false`)
```yaml
global:
  domain: "example.com"
  subDomain: false
  uriScheme: "https"

# Results in: AUTH_SERVICE_URL=https://example.com/auth
```

### Custom Auth Service URL

You can override the auto-generated URL by setting:

```yaml
workspaceAuthProxy:
  auth:
    serviceUrl: "https://custom-auth.example.com"
```

### UI Integration

The workspace UI can access the auth service URL through the `HASURA_DDN_AUTH_SERVICE_URL` environment variable to:

1. **Redirect users for authentication**
2. **Fetch workspace information**
3. **Handle token refresh**
4. **Manage user sessions**

### Example Usage in UI

```javascript
// The auth service URL is available as an environment variable
const authServiceUrl = process.env.HASURA_DDN_AUTH_SERVICE_URL;

// Redirect to auth service for login
window.location.href = `${authServiceUrl}/login?redirect=${encodeURIComponent(window.location.href)}`;

// Fetch user workspaces
const response = await fetch(`${authServiceUrl}/api/user/workspaces`, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

### Testing Auth Service URL

You can verify the auth service URL configuration:

```bash
# Check auth-proxy container
kubectl exec -it pod-name -c auth-proxy -- env | grep AUTH_SERVICE_URL

# Check workspace container
kubectl exec -it pod-name -c workspace-name -- env | grep HASURA_DDN_AUTH_SERVICE_URL
```
