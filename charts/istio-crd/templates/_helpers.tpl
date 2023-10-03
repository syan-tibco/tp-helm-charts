{{/*
Create the name of the service account to use
*/}}
{{- define "istio.controller.serviceAccountName" -}}
{{- if not .Values.serviceAccount.create -}}
{{- if (((.Values.global.cp).resources).serviceaccount).serviceAccountName -}}
{{ .Values.global.cp.resources.serviceaccount.serviceAccountName }}
{{- else -}}
{{ .Values.serviceAccount.name }}
{{- end -}}
{{- else -}}
istio-{{ .Release.Namespace }}{{- if not (eq .Values.revision "") }}-{{ .Values.revision }}{{- end }}-controller
{{- end -}}
{{- end -}}
{{- define "istio.reader.serviceAccountName" -}}
{{- if not .Values.serviceAccount.create -}}
{{- if (((.Values.global.cp).resources).serviceaccount).serviceAccountName -}}
{{ .Values.global.cp.resources.serviceaccount.serviceAccountName }}
{{- else -}}
{{ .Values.serviceAccount.name }}
{{- end -}}
{{- else -}}
istio-{{ .Release.Namespace }}{{- if not (eq .Values.revision "") }}-{{ .Values.revision }}{{- end }}-reader
{{- end -}}
{{- end -}}

