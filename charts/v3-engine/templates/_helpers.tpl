{{- define "v3-engine-st.domain" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "v3-engine-st.%s" .Values.global.domain -}}
{{- else -}}
{{- printf "%s" .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- define "v3-engine-st.path" -}}   
{{- if .Values.global.subDomain -}}      
{{- printf "" -}}
{{- else -}}
{{- printf "v3-engine-st(/|$)(.*)" -}}
{{- end -}}
{{- end -}}

{{- define "v3-engine-st.ingress.annotations" -}}   
{{- if not .Values.global.subDomain -}}      
{{- printf "nginx.ingress.kubernetes.io/rewrite-target: /$2" -}}
{{- end -}}
{{- end -}}