
{{/* Validate value of fileSystemId */}}
{{- define "dpConfigAws.validateValues.fileSystemId" -}}
{{ if .Values.storageClass.efs.enabled }}
{{ required "storageClass.efs.parameters.fileSystemId is required when efs is enabled" .Values.storageClass.efs.parameters.fileSystemId}}
{{- end -}}
{{- end -}}
