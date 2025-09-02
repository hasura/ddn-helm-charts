# DDN Workspace with Auth Proxy Integration

This document explains how to use the integrated auth-proxy functionality with the ddn-workspace Helm chart.

## Overview

The auth-proxy integration provides JWT-based authentication for DDN workspaces with support for both subdomain and path-based routing patterns. It automatically validates workspace access based on JWT claims and routes requests to the appropriate workspace containers.

## Prerequisites

- `noAuth.enabled` must be set to `true` (auth-proxy only works with no-auth mode, not password-based auth)
- A valid JWKS endpoint must be provided
- JWT tokens must contain workspace access claims in the expected format

## Configuration

### Basic Setup

```yaml
# Enable no-auth mode (required for auth-proxy)
noAuth:
  enabled: true

# Enable and configure auth-proxy
authProxy:
  enabled: true
  jwt:
    jwksUri: "https://auth.your-domain.com/ddn/.well-known/jwks"
```

### Routing Modes

#### Subdomain Routing (workspace.domain.com)

```yaml
global:
  domain: "hasura.io"
  subDomain: true  # Enable subdomain routing

# Results in: workspace-name.hasura.io → routes to workspace-name container
```

#### Path-Based Routing (domain.com/workspace/)

```yaml
global:
  domain: "hasura.io"
  subDomain: false  # Enable path-based routing

# Results in: hasura.io/workspace-name/ → routes to workspace-name container
```

### Complete Configuration Example

```yaml
global:
  domain: "lux-dev.hasura.me"
  subDomain: true
  uriScheme: "https"

noAuth:
  enabled: true

authProxy:
  enabled: true
  
  jwt:
    issuer: "https://auth.hasura.io/ddn/token"
    audience: "workspaces"
    jwksUri: "https://auth.lux-dev.hasura.me/ddn/.well-known/jwks"
  
  cookie:
    name: "auth-session"
    maxAge: 3600
  
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
```

## How It Works

### Authentication Flow

1. **JWT Validation**: Incoming requests are validated against the JWKS endpoint
2. **Workspace Extraction**: Workspace name is extracted from subdomain or path
3. **Access Control**: JWT claims are checked for workspace access permissions
4. **Dynamic Routing**: Requests are routed to the appropriate workspace container
5. **Path Cleaning**: For path-based routing, workspace prefix is removed from paths

### Workspace Access Validation

The auth-proxy validates that the JWT token contains the required workspace access claims:

```json
{
  "https://workspaces.hasura.io": {
    "workspace-accesses": [
      {
        "name": "workspace-name",
        "id": "workspace-id",
        ...
      }
    ]
  }
}
```

### Container Naming

The auth-proxy automatically routes to containers using the workspace name from the Helm release. The container name is generated using the `common.name` template, which typically follows the pattern:

- Release name: `my-workspace`
- Container name: `my-workspace`
- Service name: `my-workspace`

## Deployment

### Using Helm

```bash
# Deploy with auth-proxy enabled
helm install my-workspace ./charts/ddn-workspace \
  -f values-with-auth-proxy.yaml \
  --set authProxy.jwt.jwksUri="https://auth.example.com/.well-known/jwks"
```

### Environment-Specific Values

Create environment-specific values files:

```bash
# Production with subdomain routing
helm install prod-workspace ./charts/ddn-workspace \
  -f values-production-auth-proxy.yaml

# Staging with path-based routing
helm install staging-workspace ./charts/ddn-workspace \
  -f values-staging-auth-proxy.yaml
```

## Ingress Configuration

The auth-proxy automatically configures ingress based on the routing mode:

### Subdomain Routing Ingress

```yaml
# Generated automatically
spec:
  rules:
  - host: workspace-name.domain.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: workspace-name-auth-proxy
```

### Path-Based Routing Ingress

```yaml
# Generated automatically
spec:
  rules:
  - host: domain.com
    http:
      paths:
      - path: /workspace-name(/|$)(.*)
        backend:
          service:
            name: workspace-name-auth-proxy
```

## Troubleshooting

### Common Issues

1. **JWKS Fetch Failures**
   - Verify `authProxy.jwt.jwksUri` is accessible
   - Check network policies and firewall rules

2. **Workspace Access Denied**
   - Verify JWT contains correct workspace claims
   - Check workspace name matches the Helm release name

3. **Cookie Issues**
   - Verify domain and path settings match your ingress configuration
   - Check secure flag matches your URI scheme (HTTP/HTTPS)

### Debug Logging

Enable debug logging to troubleshoot issues:

```bash
# Check auth-proxy logs
kubectl logs deployment/workspace-name-auth-proxy

# Check Envoy admin interface
kubectl port-forward svc/workspace-name-auth-proxy 9901:9901
curl http://localhost:9901/clusters
```

### Health Checks

The auth-proxy includes health check endpoints:

```bash
# Check readiness
curl http://auth-proxy:9901/ready

# Check cluster status
curl http://auth-proxy:9901/clusters
```

## Security Considerations

1. **HTTPS Only**: Always use HTTPS in production (`global.uriScheme: "https"`)
2. **Secure Cookies**: Cookies are automatically marked secure for HTTPS
3. **JWT Validation**: All requests are validated against the JWKS endpoint
4. **Workspace Isolation**: Each workspace is isolated and access-controlled

## Migration

### From Password-Based Auth

To migrate from password-based authentication:

1. Set `noAuth.enabled: true`
2. Enable `authProxy.enabled: true`
3. Configure JWT settings
4. Update ingress configuration
5. Test authentication flow

### From Direct Access

To add authentication to previously unprotected workspaces:

1. Enable auth-proxy as above
2. Update client applications to include JWT tokens
3. Configure cookie-based session management
4. Test workspace access validation

## Limitations

- Only works with `noAuth.enabled: true`
- Requires valid JWKS endpoint
- JWT must contain workspace access claims
- Single workspace per deployment (no multi-tenancy within one chart deployment)
