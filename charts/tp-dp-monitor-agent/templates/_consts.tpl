{{/*
   Copyright (c) 2023. Cloud Software Group, Inc. All Rights Reserved. Confidential & Proprietary.

   File       : _consts.tpl
   Version    : 1.0.0
   Description: Template helpers defining constants for this chart.

    NOTES: 
      - this file contains values that are specific only to this chart. Edit accordingly.
*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "tp-dp-monitor-agent.consts.appName" }}tp-dp-monitor-agent{{ end -}}

{{/* Tenant name. */}}
{{- define "tp-dp-monitor-agent.consts.tenantName" }}finops{{ end -}}

{{/* Component we're a part of. */}}
{{- define "tp-dp-monitor-agent.consts.component" }}finops{{ end -}}

{{/* Team we're a part of. */}}
{{- define "tp-dp-monitor-agent.consts.team" }}tp-finops{{ end -}}
{{- define "tp-dp-monitor-agent.consts.fluentbit.buildNumber" }}1.9.4{{ end -}}

{{- define "tp-dp-monitor-agent.const.jfrogImageRepo" }}platform/finops{{end}}
{{- define "tp-dp-monitor-agent.const.ecrImageRepo" }}pdp{{end}}
{{- define "tp-dp-monitor-agent.const.acrImageRepo" }}pdp{{end}}
{{- define "tp-dp-monitor-agent.const.harborImageRepo" }}pdp{{end}}
{{- define "tp-dp-monitor-agent.const.defaultImageRepo" }}pdp{{end}}
 
{{- define "tp-dp-monitor-agent.image.registry" }}
  {{- .Values.global.cp.containerRegistry.url }}
{{- end -}}
 
{{/* set repository based on the registry url. We will have different repo for each one. */}}
{{- define "tp-dp-monitor-agent.image.repository" -}}
  {{- if contains "jfrog.io" (include "tp-dp-monitor-agent.image.registry" .) }}
    {{- include "tp-dp-monitor-agent.const.jfrogImageRepo" .}}
  {{- else if contains "amazonaws.com" (include "tp-dp-monitor-agent.image.registry" .) }}
    {{- include "tp-dp-monitor-agent.const.ecrImageRepo" .}}
  {{- else if contains "azurecr.io" (include "tp-dp-monitor-agent.image.registry" .) }}
    {{- include "tp-dp-monitor-agent.const.acrImageRepo" .}}
  {{- else if contains "reldocker.tibco.com" (include "tp-dp-monitor-agent.image.registry" .) }}
    {{- include "tp-dp-monitor-agent.const.harborImageRepo" .}}
  {{- else }}
    {{- include "tp-dp-monitor-agent.const.defaultImageRepo" .}}
  {{- end }}
{{- end -}}