{{/* Validate required serviceEnvVars */}}
{{- define "mychart.validateServiceEnvVars" -}}
  {{- required "ddnCliApiEnvVars.JWKS_URI is required" .Values.ddnCliApiEnvVars.JWKS_URI | quote -}}
  {{- required "ddnCliApiEnvVars.SSO_GROUP_CLAIM_KEY is required" .Values.ddnCliApiEnvVars.SSO_GROUP_CLAIM_KEY | quote -}}
  {{- required "ddnCliApiEnvVars.DDN_CLI_PAT_TOKEN is required" .Values.ddnCliApiEnvVars.DDN_CLI_PAT_TOKEN | quote -}}
  {{- required "ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT is required" .Values.ddnCliApiEnvVars.CP_GRAPHQL_ENDPOINT | quote -}}
  {{- required "ddnCliApiEnvVars.HASURA_GRAPHQL_ADMIN_SECRET is required" .Values.ddnCliApiEnvVars.HASURA_GRAPHQL_ADMIN_SECRET | quote -}}
{{- end }}

{{- define "ddn-cli-api.domain" -}}
{{- $domain := required "Error: .Values.global.domain is required!" .Values.global.domain -}}
{{- if .Values.global.subDomain -}}      
{{- printf "%s.%s" (include "common.name" .) .Values.global.domain -}}
{{- else -}}
{{- printf "%s" .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- define "ddn-cli-api.path" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "" -}}
{{- else -}}
{{- printf "%s(/|$)(.*)" (include "common.name" .) -}}
{{- end -}}
{{- end -}}

{{- define "ddn-cli-api.ingress.annotations" -}}   
{{- if not .Values.global.subDomain -}}      
{{- printf "nginx.ingress.kubernetes.io/rewrite-target: /$2" -}}
{{- end -}}
{{- end -}}

{{- define "common.secretsName" -}}   
{{- printf "%s-secrets" (include "common.name" .) -}}
{{- end -}}
