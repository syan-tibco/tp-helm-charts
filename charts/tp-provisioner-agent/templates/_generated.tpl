{{/*
   Copyright (c) 2023 Cloud Software Group, Inc.
   All Rights Reserved.

   File       : _generated.tpl
   Version    : 1.0.0
   Description: Template helpers defining constants for this chart.

    NOTES:
      - This file will be generated by the build server. DO NOT EDIT!
*/}}

{{/* The build number, also used as docker image image tag */}}
{{- define "tp-provisioner-agent.generated.buildNumber" }}latest{{end -}}

{{/* The build timestamp, used as a label to force pod upgrade even when deployment.yaml was not changed (dev workflow) */}}
{{- define "tp-provisioner-agent.generated.buildTimestamp" }}unknown{{end -}}