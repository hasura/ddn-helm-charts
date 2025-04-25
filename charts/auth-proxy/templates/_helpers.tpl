{{/* Validate required serviceEnvVars */}}
{{- define "mychart.validateServiceEnvVars" -}}
  {{- required "authProxyEnvVars.ADFS_PROVIDER_ENDPOINT is required" .Values.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT | quote -}}
  {{- required "authProxyEnvVars.RESOURCE is required" .Values.authProxyEnvVars.RESOURCE | quote -}}
  {{- required "authProxyEnvVars.REGION is required" .Values.authProxyEnvVars.REGION | quote -}}
{{- end }}

{{- define "auth-proxy.domain" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "auth-proxy.%s" .Values.global.domain -}}
{{- else -}}
{{- printf "%s" .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- define "auth-proxy.path" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "" -}}
{{- else -}}
{{- printf "auth-proxy(/|$)(.*)" -}}
{{- end -}}
{{- end -}}

{{- define "auth-proxy.ingress.annotations" -}}   
{{- if not .Values.global.subDomain -}}      
{{- printf "nginx.ingress.kubernetes.io/rewrite-target: /$2" -}}
{{- end -}}
{{- end -}}
