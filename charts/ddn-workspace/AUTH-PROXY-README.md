# DDN Workspace with Auth Proxy Integration

This document explains how to use the integrated auth-proxy functionality with the ddn-workspace Helm chart.

## Overview

The auth-proxy integration provides authentication for DDN workspaces with support for both subdomain and path-based routing patterns. It automatically validates workspace access and routes requests to the workspace container.

## Prerequisites

- `noAuth.enabled` must be set to `true` (auth-proxy only works with no-auth mode, not password-based auth)

## Configuration

### Basic Setup

```yaml
# Enable no-auth mode (required for auth-proxy)
noAuth:
  enabled: true

# Enable and configure auth-proxy
authProxy:
  enabled: true
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

  cookie:
    name: "auth-session"
    maxAge: 3600  # Session expiry in seconds (1 hour)
    # Examples:
    # maxAge: 1800   # 30 minutes
    # maxAge: 7200   # 2 hours
    # maxAge: 28800  # 8 hours

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

1. **Workspace Extraction**: Workspace name is extracted from subdomain or path
2. **Access Control**: Workspace access is validated through GraphQL queries

### Workspace Access Validation

The auth-proxy validates workspace access through GraphQL queries to the data service.

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
  -f values-with-auth-proxy.yaml
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

1. **Workspace Access Denied**
   - Check workspace name matches the Helm release name
   - Verify GraphQL data service is accessible

2. **Cookie Issues**
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
