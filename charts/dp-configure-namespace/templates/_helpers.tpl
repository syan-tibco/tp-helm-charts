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
{{- define "dp-configure-namespace.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-configure-namespace.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "dp-configure-namespace.appName" }}dp-configure-namespace{{ end -}}

{{/* Tenant name. */}}
{{- define "dp-configure-namespace.tenantName" }}infrastructure{{ end -}}

{{- define "dp-configure-namespace.part-of" }}"tibco-platform"{{ end -}}

{{/* Component we're a part of. */}}
{{- define "dp-configure-namespace.component" }}tibco-platform-data-plane{{ end -}}

{{/* Team we're a part of. */}}
{{- define "dp-configure-namespace.team" }}cic-compute{{ end -}}

{{/* Data plane workload type */}}
{{- define "dp-configure-namespace.workloadType" }}infra{{ end -}}

{{/* Data plane primary namespace name */}}
{{- define "dp-configure-namespace.primaryNamespaceName" }}{{ required "global.tibco.primaryNamespaceName is required" .Values.global.tibco.primaryNamespaceName }}{{ end -}}

{{/* Data plane service account */}}
{{- define "dp-configure-namespace.serviceAccount" }}{{ required "global.tibco.serviceAccount is required" .Values.global.tibco.serviceAccount }}{{ end -}}

{{/* Data plane dataPlane id */}}
{{- define "dp-configure-namespace.dataPlaneId" }}{{ required "global.tibco.dataPlaneId is required" .Values.global.tibco.dataPlaneId }}{{ end -}}

{{/*
================================================================
                  SECTION LABELS
================================================================   
*/}}

{{/*
Common labels
*/}}
{{- define "dp-configure-namespace.labels" -}}
helm.sh/chart: {{ include "dp-configure-namespace.chart" . }}
{{ include "dp-configure-namespace.selectorLabels" . }}
{{ include "dp-configure-namespace.platformLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-configure-namespace.team" .}}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "dp-configure-namespace.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-configure-namespace.name" . }}
app.kubernetes.io/component: {{ include "dp-configure-namespace.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-configure-namespace.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Platform labels to be added in all the resources created by this chart.*/}}
{{- define "dp-configure-namespace.platformLabels" -}}
platform.tibco.com/dataPlane-id: {{ .Values.global.tibco.dataPlaneId }}
{{- end -}}
