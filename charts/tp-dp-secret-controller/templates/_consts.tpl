{{/* 
   Copyright (c) 2023 Cloud Software Group, Inc.
   All Rights Reserved.

   File       : _consts.tpl
   Version    : 1.0.0
   Description: Template helpers defining constants for this chart.
   
    NOTES: 
      - this file contains values that are specific only to this chart. Edit accordingly.
*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "tp-dp-secret-controller.consts.appName" }}dp-secret-controller{{ end -}}

{{/* Tenant name. */}}
{{- define "tp-dp-secret-controller.consts.tenantName" }}infrastructure{{ end -}}

{{/* Component we're a part of. */}}
{{- define "tp-dp-secret-controller.consts.component" }}tibco-platform-data-plane{{ end -}}

{{/* Team we're a part of. */}}
{{- define "tp-dp-secret-controller.consts.team" }}cic-compute{{ end -}}

{{/* Data plane workload type */}}
{{- define "tp-dp-secret-controller.consts.workloadType" }}infra{{ end -}}