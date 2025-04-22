{{- define "validate.elasticsearch.credentialsProvider" -}}
  {{- $val := .Values.connectorEnvVars.ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM | default "" -}}
  {{- if and (ne $val "api-key") (ne $val "service-token") (ne $val "") }}
    {{- fail (printf "Invalid value for ELASTICSEARCH_CREDENTIALS_PROVIDER_MECHANISM: '%s'. Must be 'api-key' or 'service-token'." $val) }}
  {{- end }}
{{- end }}
