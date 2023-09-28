{{/* 
   Copyright (c) 2023 Cloud Software Group, Inc.
   All Rights Reserved.

   File       : _shared.tpl
   Version    : 1.0.0
   Description: Template helpers that can be shared with other charts. 
   
    NOTES: 
      - Helpers below are making some assumptions regarding files Chart.yaml and values.yaml. Change carefully!
      - Any change in this file needs to be synchronized with all charts
*/}}

{{/*
    ===========================================================================
    SECTION: labels
    ===========================================================================
*/}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "tp-cp-proxy.shared.labels.chartLabelValue" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels used by the resources in this chart
*/}}
{{- define "tp-cp-proxy.shared.labels.selector" -}}
app.kubernetes.io/name: {{ include "tp-cp-proxy.consts.appName" . }}
app.kubernetes.io/component: {{ include "tp-cp-proxy.consts.component" . }}
app.kubernetes.io/part-of: {{ include "tp-cp-proxy.consts.team" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Standard labels added to all resources created by this chart. 
Includes labels used as selectors (i.e. template "labels.selector")
*/}}
{{- define "tp-cp-proxy.shared.labels.standard" -}}
{{ include  "tp-cp-proxy.shared.labels.selector" . }}
{{ include "tp-cp-proxy.shared.labels.platform" . }}
app.cloud.tibco.com/created-by: {{ include "tp-cp-proxy.consts.team" . }}
app.cloud.tibco.com/tenant-name: {{ include "tp-cp-proxy.consts.tenantName" . }}
helm.sh/chart: {{ include "tp-cp-proxy.shared.labels.chartLabelValue" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}

{{/* Platform labels to be added in all the resources created by this chart.*/}}
{{- define "tp-cp-proxy.shared.labels.platform" -}}
platform.tibco.com/dataplane-id: {{ .Values.global.cp.dataplaneId }}
platform.tibco.com/workload-type: {{ include "tp-cp-proxy.consts.workloadType" .}}
platform.tibco.com/capability-instance-id: {{ .Values.global.cp.instanceId }}
egress.networking.platform.tibco.com/internet-web: enable
networking.platform.tibco.com/kubernetes-api: enable
{{- end }}