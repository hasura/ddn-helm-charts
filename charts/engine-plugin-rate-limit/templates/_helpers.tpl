{{- define "common.name" -}}
{{- $envOverrides := index .Values (tpl (default .Chart.Name .Values.name) .) -}}
{{- $baseCommonValues := (default dict .Values.common) | deepCopy -}}
{{- $values := dict "Values" (mustMergeOverwrite $baseCommonValues .Values $envOverrides) -}}
{{- with mustMergeOverwrite . $values -}}
{{ if and (ne .Release.Name "RELEASE-NAME") (.Values.useReleaseName) }}
{{- printf "%s-%s" .Release.Name (default .Chart.Name .Values.name) -}}
{{- else -}}
{{- default .Chart.Name .Values.name -}}
{{ end }}
{{- end }}
{{- end }}