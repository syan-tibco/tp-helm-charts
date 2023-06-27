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
