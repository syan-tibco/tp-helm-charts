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
{{- define "dp-core-rbac.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dp-core-rbac.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "dp-core-rbac.appName" }}dp-core-rbac{{ end -}}

{{/* Tenant name. */}}
{{- define "dp-core-rbac.tenantName" }}infrastructure{{ end -}}

{{- define "dp-core-rbac.part-of" }}"tibco-platform"{{- end }}

{{/* Component we're a part of. */}}
{{- define "dp-core-rbac.component" }}tibco-platform-data-plane{{ end -}}

{{/* Team we're a part of. */}}
{{- define "dp-core-rbac.team" }}cic-compute{{ end -}}

{{/* Data plane workload type */}}
{{- define "dp-core-rbac.workloadType" }}infra{{ end -}}

{{/* Cluster Role Name Prefix */}}
{{- define "dp-core-rbac.clusterRoleName" }}{{ .Values.global.tibco.dataPlaneId}}-cluster-role{{ end -}}

{{/* Cluster Role Binding Name Prefix */}}
{{- define "dp-core-rbac.clusterRoleBindingName" }}{{ .Values.global.tibco.dataPlaneId}}-cluster-role-binding{{ end -}}

{{/* Role Binding Name Prefix */}}
{{- define "dp-core-rbac.roleBindingName" }}{{ .Values.global.tibco.dataPlaneId}}-role-binding{{ end -}}


{{/*
================================================================
                  SECTION LABELS
================================================================   
*/}}

{{/*
Common labels
*/}}
{{- define "dp-core-rbac.labels" -}}
helm.sh/chart: {{ include "dp-core-rbac.chart" . }}
{{ include "dp-core-rbac.selectorLabels" . }}
{{ include "dp-core-rbac.platformLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.cloud.tibco.com/created-by: {{ include "dp-core-rbac.team" .}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dp-core-rbac.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dp-core-rbac.name" . }}
app.kubernetes.io/component: {{ include "dp-core-rbac.component" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "dp-core-rbac.part-of" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Platform labels to be added in all the resources created by this chart.*/}}
{{- define "dp-core-rbac.platformLabels" -}}
platform.tibco.com/dataplane-id: {{ .Values.global.tibco.dataPlaneId }}
platform.tibco.com/workload-type: {{ include "dp-core-rbac.workloadType" . }}
{{- end -}}
