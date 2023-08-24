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
{{- define "dp-config-namespace.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-config-namespace.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "dp-config-namespace.appName" }}dp-config-namespace{{ end -}}

{{/* Tenant name. */}}
{{- define "dp-config-namespace.tenantName" }}infrastructure{{ end -}}

{{- define "dp-config-namespace.part-of" }}"tibco-platform"{{- end }}

{{/* Component we're a part of. */}}
{{- define "dp-config-namespace.component" }}tibco-platform-data-plane{{ end -}}

{{/* Team we're a part of. */}}
{{- define "dp-config-namespace.team" }}cic-compute{{ end -}}

{{/* Data plane workload type */}}
{{- define "dp-config-namespace.workloadType" }}infra{{ end -}}

{{/* Cluster Role Name Prefix */}}
{{- define "dp-config-namespace.clusterRoleNamePrefix" }}cluster-role{{ end -}}

{{/* Cluster Role Binding Name Prefix */}}
{{- define "dp-config-namespace.clusterRoleBindingNamePrefix" }}cluster-role-binding{{ end -}}

{{/* Role Binding Name Prefix */}}
{{- define "dp-config-namespace.roleBindingNamePrefix" }}role-binding{{ end -}}


{{/*
================================================================
                  SECTION LABELS
================================================================   
*/}}

{{/*
Common labels
*/}}
{{- define "dp-config-namespace.labels" -}}
helm.sh/chart: {{ include "dp-config-namespace.chart" . }}
{{ include "dp-config-namespace.selectorLabels" . }}
{{ include "dp-config-namespace.platformLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-config-namespace.team" .}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dp-config-namespace.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-config-namespace.name" . }}
app.kubernetes.io/component: {{ include "dp-config-namespace.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-config-namespace.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Platform labels to be added in all the resources created by this chart.*/}}
{{- define "dp-config-namespace.platformLabels" -}}
platform.tibco.com/dataplane-id: {{ .Values.global.tibco.dataPlaneId }}
platform.tibco.com/workload-type: {{ include "dp-config-namespace.workloadType" . }}
{{- end -}}
