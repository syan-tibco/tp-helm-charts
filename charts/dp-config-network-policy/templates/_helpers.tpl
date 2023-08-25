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
{{- define "dp-config-network-policy.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-config-network-policy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "dp-config-network-policy.appName" }}dp-config-network-policy{{ end -}}

{{/* Tenant name. */}}
{{- define "dp-config-network-policy.tenantName" }}infrastructure{{ end -}}

{{- define "dp-config-network-policy.part-of" }}"tibco-platform"{{- end }}

{{/* Component we're a part of. */}}
{{- define "dp-config-network-policy.component" }}tibco-platform-data-plane{{ end -}}

{{/* Team we're a part of. */}}
{{- define "dp-config-network-policy.team" }}cic-compute{{ end -}}

{{/* Data plane workload type */}}
{{- define "dp-config-network-policy.workloadType" }}infra{{ end -}}


{{/*
================================================================
                  SECTION LABELS
================================================================   
*/}}

{{/*
Common labels
*/}}
{{- define "dp-config-network-policy.labels" -}}
helm.sh/chart: {{ include "dp-config-network-policy.chart" . }}
{{ include "dp-config-network-policy.selectorLabels" . }}
{{ include "dp-config-network-policy.platformLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-config-network-policy.team" .}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dp-config-network-policy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-config-network-policy.name" . }}
app.kubernetes.io/component: {{ include "dp-config-network-policy.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-config-network-policy.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Platform labels to be added in all the resources created by this chart.*/}}
{{- define "dp-config-network-policy.platformLabels" -}}
platform.tibco.com/dataplane-id: {{ .Values.global.tibco.dataPlaneId }}
platform.tibco.com/workload-type: {{ include "dp-config-network-policy.workloadType" . }}
{{- end -}}
