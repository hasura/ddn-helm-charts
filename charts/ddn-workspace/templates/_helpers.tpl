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

{{- define "conditionally.b64enc" -}}
{{- $str := . -}}
{{- if not (regexMatch "^[A-Za-z0-9+/=]+$" $str) -}}  # Check if the string is not base64
  {{- $str | b64enc }}  # Encode it if not base64
{{- else -}}
  {{- $str }}  # Return the original string if it's already base64
{{- end -}}
{{- end -}}