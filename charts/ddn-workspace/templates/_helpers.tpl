{{- define "ddn-workspace.domain" -}}
{{- $domain := required "Error: .Values.global.domain is required!" .Values.global.domain -}}
{{- if .Values.global.subDomain -}}      
{{- printf "%s.%s" (include "common.name" .) .Values.global.domain -}}
{{- else -}}
{{- printf "%s" .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.path" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "" -}}
{{- else -}}
{{- printf "%s(/|$)(.*)" (include "common.name" .) -}}
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.ingress.annotations" -}}   
{{- if not .Values.global.subDomain -}}      
{{- printf "nginx.ingress.kubernetes.io/rewrite-target: /$2" -}}
{{- end -}}
{{- end -}}

{{- define "common.secretsName" -}}   
{{- printf "%s-secrets" (include "common.name" .) -}}
{{- end -}}

{{/*
Auth Proxy helpers
*/}}
{{- define "ddn-workspace.authProxy.enabled" -}}
{{- and .Values.noAuth.enabled .Values.authProxy.enabled -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.name" -}}
{{- printf "%s-auth-proxy" (include "common.name" .) -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.routingMode" -}}
{{- if .Values.global.subDomain -}}
subdomain
{{- else -}}
path
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.cookieDomain" -}}
{{- if .Values.global.subDomain -}}
{{- printf "%s.%s" (include "common.name" .) .Values.global.domain -}}
{{- else -}}
{{- printf "%s" .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.cookiePath" -}}
{{- if .Values.global.subDomain -}}
/
{{- else -}}
{{- printf "/%s/" (include "common.name" .) -}}
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.cookieSecure" -}}
{{- if eq .Values.global.uriScheme "https" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.workspaceServiceName" -}}
{{- include "common.name" . -}}
{{- end -}}

{{- define "ddn-workspace.authProxy.authServiceUrl" -}}
{{- if .Values.authProxy.auth.serviceUrl -}}
{{- .Values.authProxy.auth.serviceUrl -}}
{{- else -}}
{{- if .Values.global.subDomain -}}
{{- printf "%s://auth.%s" .Values.global.uriScheme .Values.global.domain -}}
{{- else -}}
{{- printf "%s://%s/auth" .Values.global.uriScheme .Values.global.domain -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ddn-workspace.securityHeaders" -}}
- header:
    key: "Strict-Transport-Security"
    value: "max-age=31536000; includeSubDomains"
- header:
    key: "X-Frame-Options"
    value: "SAMEORIGIN"
- header:
    key: "Referrer-Policy"
    value: "strict-origin"
- header:
    key: "X-Content-Type-Options"
    value: "nosniff"
- header:
    key: "X-Xss-Protection"
    value: "1; mode=block"
- header:
    key: "Content-Security-Policy"
    value: "default-src 'self'; img-src 'self' data:; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
{{- end -}}
