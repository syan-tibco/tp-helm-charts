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
{{- define "dp-core-infrastructure.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-core-infrastructure.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dp-core-infrastructure.component" -}}
{{- "dp-infrastructure" }}
{{- end }}

{{- define "dp-core-infrastructure.part-of" -}}
{{- "tibco-platform" }}
{{- end }}

{{- define "dp-core-infrastructure.team" -}}
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
{{- define "dp-core-infrastructure.labels" -}}
helm.sh/chart: {{ include "dp-core-infrastructure.chart" . }}
{{ include "dp-core-infrastructure.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-core-infrastructure.team" .}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dp-core-infrastructure.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-core-infrastructure.name" . }}
app.kubernetes.io/component: {{ include "dp-core-infrastructure.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-core-infrastructure.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
