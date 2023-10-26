{{/* jfrog repo hack to change the repo image path; this should be handled by the upper layer! */}}
{{- define "tibco.image.repository.oauth2proxy" -}}
  {{- if contains "jfrog.io" .Values.image.repository }}{{ .Values.image.repository | replace "stratosphere" "platform/infra" }}
  {{- else }}
    {{- .Values.image.repository }}
  {{- end }}
{{- end -}}

{{/* init container image used for registering OAuth client and creating a kubernetes secret with it */}}
{{- define "tibco.image.repository.alpine" -}}
  {{- if contains "jfrog.io" .Values.global.cp.containerRegistry.url }}{{ .Values.global.cp.containerRegistry.url }}/platform/infra/{{ .Values.tibco.initContainer.image }}:{{ .Values.tibco.initContainer.tag }}
  {{- else }}
    {{- .Values.global.cp.containerRegistry.url }}/stratosphere/{{ .Values.tibco.initContainer.image }}:{{ .Values.tibco.initContainer.tag }}
  {{- end }}
{{- end -}}