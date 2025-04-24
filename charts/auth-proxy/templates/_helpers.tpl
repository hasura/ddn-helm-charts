{{/* Validate required serviceEnvVars */}}
{{- define "mychart.validateServiceEnvVars" -}}
  {{- required "serviceEnvVars.ADFS_PROVIDER_ENDPOINT is required" .Values.serviceEnvVars.ADFS_PROVIDER_ENDPOINT | quote -}}
  {{- required "serviceEnvVars.RESOURCE is required" .Values.serviceEnvVars.RESOURCE | quote -}}
  {{- required "serviceEnvVars.REGION is required" .Values.serviceEnvVars.REGION | quote -}}
{{- end }}
