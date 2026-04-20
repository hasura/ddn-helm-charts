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

{{- define "common.labels" -}}
app: {{ template "common.name" . }}
{{- if (.Values.labels).group }}
group: {{ .Values.labels.group }}
{{- end }}
{{- range $key, $val := .Values.additionalLabels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}

{{- define "common.image" -}}
{{- $tag := ( required "Tag is mandatory" ( coalesce .tag (.Values.global).tag (.Chart).AppVersion ) ) }}
{{- if or (contains "/" .repository) (not ($.Values.global).containerRegistry) -}}
{{- printf "%s:%s" ( required "Repository is mandatory" ( coalesce .repository ($.Values.global).containerRegistry ) ) $tag -}}
{{- else -}}
{{- $tagSuffix := "" }}
{{- if .tagSuffix }}
  {{- $tagSuffix = .tagSuffix }}
{{- end }}
{{- printf "%s/%s:%s%s" ($.Values.global).containerRegistry .repository $tag $tagSuffix -}}
{{- end -}}
{{- end -}}

{{- define "common.namespace" -}}
{{- print (coalesce .Values.namespace (.Values.global).namespace .Release.Namespace) -}}
{{- end -}}

{{- define "common.getServiceHost" -}}
{{- $sources := .catalog -}}
{{- if .additionalCatalog }}
  {{- $sources = append .catalog .additionalCatalog }}
{{- end }}
{{- $serviceName := .name -}}
{{- range $sources -}}
  {{- if eq .name $serviceName -}}
    {{- coalesce .app .name -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.getServicePort" -}}
{{- $sources := .catalog -}}
{{- if .additionalCatalog }}
  {{- $sources = append .catalog .additionalCatalog }}
{{- end }}
{{- $serviceName := .name -}}
{{- range $sources -}}
  {{- if eq .name $serviceName -}}
    {{- .port -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.tplOrYaml" -}}
{{- if typeIs "string" .value -}}
  {{- tpl  .value . -}}
{{- else -}}
  {{- toYaml .value -}}
{{- end -}}
{{- end -}}


{{- define "common.isIngressHttps" -}}
  {{- $scheme := ((.Values.global).ingress).uriScheme | default (.Values.global).uriScheme -}}
  {{- if eq $scheme "https" }}true{{ else }}false{{ end }}
{{- end }}

{{- define "common.hpaEnabled" -}}
  {{- or .Values.hpa.enabled (and (ne .Values.hpa.enabled false) ((.Values.global).hpa).enabled) -}}
{{- end }}

{{- define "common.enableExternalSecretsSupport" -}}
  {{- and .Values.externalSecrets.enabled .Values.global.externalSecrets.enabled -}}
{{- end }}

{{- define "common.secretRefresherContainer" -}}
  {{ with .Values.externalSecrets.secretRefresher }}
  - name: {{ ternary "secret-refresher-init" "secret-refresher" (eq (default "" $.externalSecretsOverrideType) "initcontainer") | quote }} 
    image: "{{ template "common.image" (dict "Values" $.Values "Chart" $.Chart "repository" .image.repository "tag" (coalesce ((($.Values.global).externalSecrets).image).tag .image.tag)) }}"
    imagePullPolicy: {{ .image.pullPolicy }}
    {{- if (not (($.Values.global).securityContext).disabled) }}
    securityContext:
      runAsUser: 1001
    {{- end }}     
    volumeMounts:
      - name: secrets-refresh-config
        mountPath: /config.yaml
        subPath: config.yaml
      - name: secrets-refresh-config
        mountPath: /config-init.yaml
        subPath: config-init.yaml
      - name: shared-secret-volume
        mountPath: /secrets
    env:
      - name: CONFIG_FILE
        value: {{ ternary "/config-init.yaml" "/config.yaml" (eq (default "" $.externalSecretsOverrideType) "initcontainer") | quote }}  
      {{- if .additionalEnv }}
        {{- include "common.tplOrYaml" (set (deepCopy $) "value" .additionalEnv) | nindent 6 }}
      {{- end -}}
      {{- if (($.Values.global).externalSecrets).additionalEnv }}
        {{- include "common.tplOrYaml" (set (deepCopy $) "value" $.Values.global.externalSecrets.additionalEnv) | nindent 6 }}
      {{- end -}}
  {{- end }}  
{{- end }}

{{/*
Generate derived labels based on feature flags
*/}}
{{- define "common.derivedLabels" -}}
{{- $labels := dict -}}

{{- if eq "true" (include "common.enableExternalSecretsSupport" .) }}
  {{- $_ := set $labels "promptql.io/feature-secret-refresher" "true" }}
{{- end }}

{{- range $k, $v := $labels }}
{{ printf "%s: \"%s\"" $k $v }}
{{- end }}
{{- end }}

{{- define "common.derivedAnnotations" -}}
{{- $annotations := dict -}}
{{- if eq "true" (include "common.enableExternalSecretsSupport" .) -}}
  {{- $_ := set $annotations "checksum/ext-secrets-config" (include (print $.Template.BasePath "/external-secrets-config.yaml") . | sha256sum) -}}
{{- end -}}
{{- range $k, $v := $annotations -}}
{{ printf "%s: \"%s\"" $k $v }}
{{- end -}}
{{- end -}}

{{- define "common.derivedEnvs" -}}
{{- with .Values.global.externalSecrets -}}
{{- if and (eq "true" (include "common.enableExternalSecretsSupport" $)) .autoRestartOnSecretChange (eq .type "sidecar") -}}
- name: ENABLE_AUTO_RESTART_ON_SECRET_CHANGE
  value: "true"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Extract secret key references from multiline env template string
Usage: {{ include "common.extractSecretKeyRefs" (dict "context" $ "envString" .Values.env) }}
Input: Dict with context (for tpl processing) and envString (multiline YAML template string)
Output: Array of objects with from/to mappings for each secretKeyRef found

The function first processes the envString through tpl to resolve template expressions,
then parses it as YAML to extract secret key references.

Example input:
env: |
  {{- if .Values.someCondition }}
  - name: "FLYWAY_USER"
    valueFrom:
      secretKeyRef:
        name: db
        key: flyway-username
  {{- end }}
  - name: "DB_PASSWORD"
    valueFrom:
      secretKeyRef:
        name: secrets
        key: database-password

Example output:
- from: FLYWAY_USER
  to: flyway-username
- from: DB_PASSWORD
  to: database-password
*/}}
{{- define "common.extractSecretKeyRefs" -}}
{{- $context := .context -}}
{{- $envString := .envString | trim -}}
{{- if and $envString (ne $envString "") -}}
{{- $tempContext := deepCopy $context -}}
{{- $_ := set $tempContext.Values.externalSecrets "enabled" false -}}
{{- $_ := set $tempContext.Values.global.externalSecrets "enabled" false -}}
{{- $parsed := fromYamlArray (tpl $envString $tempContext) -}}
{{- $keyMappings := list -}}
{{- range $parsed -}}
  {{- if and (hasKey . "name") (hasKey . "valueFrom") -}}
    {{- if and .valueFrom (hasKey .valueFrom "secretKeyRef") -}}
      {{- if and .valueFrom.secretKeyRef (hasKey .valueFrom.secretKeyRef "key") -}}
        {{- $mapping := dict "from" .valueFrom.secretKeyRef.key "to" .name -}}
        {{- $keyMappings = append $keyMappings $mapping -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $keyMappings | toYaml -}}
{{- end -}}
{{- end -}}

{{- define "common.extractHost" -}}
{{- $url := . | trimPrefix "http://" | trimPrefix "https://" -}}
{{- $host := splitList ":" $url | first -}}
{{- $host := splitList "/" $host | first -}}
{{- $host -}}
{{- end -}}

{{- define "common.extractPort" -}}
{{- $url := . | trimPrefix "http://" | trimPrefix "https://" -}}
{{- $parts := splitList ":" $url -}}
{{- if gt (len $parts) 1 -}}
  {{- $portPart := index $parts 1 | splitList "/" -}}
  {{- $port := index $portPart 0 -}}
  {{- $port -}}
{{- else -}}
  {{- "" -}}
{{- end -}}
{{- end -}}

