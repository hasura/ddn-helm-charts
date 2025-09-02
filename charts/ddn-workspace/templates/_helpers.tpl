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
{{- printf ".%s" .Values.global.domain -}}
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
