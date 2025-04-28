{{- define "validate.elasticsearch.credentialsProvider" -}}
  {{- $val := .Values.connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM | default "" -}}
  {{- if and (ne $val "api-key") (ne $val "service-token") (ne $val "bearer-token") (ne $val "") }}
    {{- fail (printf "Invalid value for ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM: '%s'. Must be 'api-key', 'service-token' or 'bearer-token'." $val) }}
  {{- end }}
{{- end }}

{{/* Validate required serviceEnvVars when authService sidecar is enabled */}}
{{- define "mychart.validateAuthProxyServiceEnvVars" -}}
  {{- if .Values.authProxy.enabled }}
    {{- required "authProxy.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT is required" .Values.authProxy.authProxyEnvVars.ADFS_PROVIDER_ENDPOINT | quote -}}
    {{- required "authProxy.authProxyEnvVars.RESOURCE is required" .Values.authProxy.authProxyEnvVars.RESOURCE | quote -}}
    {{- required "authProxy.authProxyEnvVars.REGION is required" .Values.authProxy.authProxyEnvVars.REGION | quote -}}
    {{- required "connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI is required" .Values.connectorEnvVars.HASURA_CREDENTIALS_PROVIDER_URI | quote -}}
  {{- end }}
{{- end }}
