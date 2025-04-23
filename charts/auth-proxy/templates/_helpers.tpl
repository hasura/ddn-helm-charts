{{/* Validate required serviceEnvVars */}}
{{- define "mychart.validateServiceEnvVars" -}}
  {{- required "serviceEnvVars.AUTH_WEBHOOK is required" .Values.serviceEnvVars.AUTH_WEBHOOK | quote -}}
  {{- required "serviceEnvVars.GRANT_TYPE is required" .Values.serviceEnvVars.GRANT_TYPE | quote -}}
  {{- required "serviceEnvVars.CLIENT_ID is required" .Values.serviceEnvVars.CLIENT_ID | quote -}}
  {{- required "serviceEnvVars.RESOURCE is required" .Values.serviceEnvVars.RESOURCE | quote -}}
  {{- required "serviceEnvVars.USERNAME is required" .Values.serviceEnvVars.USERNAME | quote -}}
  {{- required "serviceEnvVars.PASSWORD is required" .Values.serviceEnvVars.PASSWORD | quote -}}
{{- end }}
