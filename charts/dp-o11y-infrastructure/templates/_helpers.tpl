{{/* 
   Copyright (c) 2023 Cloud Software Group, Inc.
   All Rights Reserved.

   File       : _helper.tpl
   Version    : 1.0.0
   Description: Template helper used across chart. 
   
    NOTES: 
      - Helpers below are making some assumptions regarding files Chart.yaml and values.yaml. Change carefully!
      - Any change in this file needs to be synchronized with all charts
*/}}


{{/*
================================================================
                  SECTION COMMON VARS
================================================================   
*/}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dp-o11y-infrastructure.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-o11y-infrastructure.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dp-o11y-infrastructure.component" -}}
{{- "dp-infrastructure" }}
{{- end }}

{{- define "dp-o11y-infrastructure.part-of" -}}
{{- "o11y" }}
{{- end }}

{{- define "dp-o11y-infrastructure.team" -}}
{{- "cic-compute" }}
{{- end }}


{{/*
================================================================
                  SECTION LABELS
================================================================   
*/}}

{{/*
Common labels
*/}}
{{- define "dp-o11y-infrastructure.labels" -}}
helm.sh/chart: {{ include "dp-o11y-infrastructure.chart" . }}
{{ include "dp-o11y-infrastructure.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-o11y-infrastructure.team" .}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dp-o11y-infrastructure.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-o11y-infrastructure.name" . }}
app.kubernetes.io/component: {{ include "dp-o11y-infrastructure.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-o11y-infrastructure.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
