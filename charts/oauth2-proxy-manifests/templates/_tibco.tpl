{{/* jfrog repo hack to change the repo image path; this should be handled by the upper layer! */}}
{{- define "tibco.image.repository.oauth2proxy" -}}
  {{- if contains "jfrog.io" .Values.image.repository }}{{ .Values.image.repository | replace "stratosphere" "platform/infra" }}
  {{- else }}
    {{- .Values.image.repository }}
  {{- end }}
{{- end -}}