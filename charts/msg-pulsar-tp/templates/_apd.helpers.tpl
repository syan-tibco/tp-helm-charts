
{{/*
MSGDP Pulsar (aka. Quasar, APD) Helpers
#
# Copyright (c) 2023-2024. Cloud Software Group, Inc.
# This file is subject to the license terms contained
# in the license file that is distributed with this file.
#

*/}}

{{/*
need.msg.apd.params
*/}}
{{ define "need.msg.apd.params" }}
#
{{-  $dpParams := include "need.msg.dp.params" . | fromYaml -}}
#
{{-  $apdDefaultFullImage := printf "%s/%s/msg-pulsar-all:3.0.2-2" $dpParams.dp.registry $dpParams.dp.repo -}}
{{-  $opsDefaultFullImage := printf "%s/%s/msg-dp-ops:1.1.0-1" $dpParams.dp.registry $dpParams.dp.repo -}}
{{-  $apdDefaultImageTag := "3.0.2-2" -}}
# Set APD defaults
{{- $apdImage := ternary $apdDefaultFullImage .Values.apd.image ( not .Values.apd.image ) -}}
{{- $name := ternary .Release.Name .Values.apd.name ( not .Values.apd.name ) -}}
{{- $sizing := ternary  "small" .Values.apd.sizing ( not  .Values.apd.sizing ) -}}
{{- $use := ternary  "dev" .Values.apd.use ( not  .Values.apd.use ) -}}
{{- $isProduction := false -}}
{{- $allowNodeSkew := "yes" -}}
{{- $allowZoneSkew := "yes" -}}
{{- $msgStorageType := "emptyDir" -}}
{{- $msgStorageName := "none" -}}
{{- $msgStorageSize :=  "4Gi" -}}
{{- $dpCreateSharedPvc := "no" -}}
{{- $logStorageType := "useMsgData" -}}
{{- $logStorageName := "none" -}}
{{- $logStorageSize :=  "4Gi" -}}
{{- $pvcShareName :=  "none" -}}
{{- $pvcShareSize :=  $logStorageSize -}}
  {{- if .Values.apd.msgData -}}
    {{- $msgStorageType = ternary  $msgStorageType .Values.apd.msgData.storageType ( not  .Values.apd.msgData.storageType ) -}}
    {{- $msgStorageName = ternary  $msgStorageName .Values.apd.msgData.storageName ( not  .Values.apd.msgData.storageName ) -}}
    {{- $msgStorageSize = ternary  $msgStorageSize .Values.apd.msgData.storageSize ( not  .Values.apd.msgData.storageSize ) -}}
  {{- end -}}
  {{- if .Values.apd.logs -}}
    {{- $logStorageType = ternary  $logStorageType .Values.apd.logs.storageType ( not  .Values.apd.logs.storageType ) -}}
    {{- $logStorageName = ternary  $logStorageName .Values.apd.logs.storageName ( not  .Values.apd.logs.storageName ) -}}
    {{- $logStorageSize = ternary  $logStorageSize .Values.apd.logs.storageSize ( not  .Values.apd.logs.storageSize ) -}}
  {{- end -}}
  {{- if eq "sharedStorageClass" $logStorageType -}}
    {{- $dpCreateSharedPvc = "yes" -}}
    {{- $logStorageType = "sharedPvc" -}}
    {{- $pvcShareName = ( printf "%s-share" $name ) -}}
    {{- $logStorageName = $pvcShareName -}}
  {{- end -}}
  {{- if eq "sharedStorageClass" $msgStorageType -}}
    {{- $dpCreateSharedPvc = "yes" -}}
    {{- $msgStorageType = "sharedPvc" -}}
    {{- $pvcShareName = ( printf "%s-share" $name ) -}}
    {{- $msgStorageName = $pvcShareName -}}
    {{- $pvcShareSize :=  $logStorageSize -}}
  {{- end -}}
# Fill in $apdParams yaml
{{ include "need.msg.dp.params" . }}
ops:
  image: {{ $opsDefaultFullImage }}
apd:
  name: {{ $name }}
  imageFullName: {{ $apdImage }}
  imageTag: {{ .Values.defaultPulsarImageTag | default $apdDefaultImageTag }}
  sizing: {{ $sizing }}
  use: {{ $use }}
  isProduction: {{ $isProduction }}
  pvcShareName: {{ $pvcShareName }}
  pvcShareSize: {{ $pvcShareSize }}
  msgData: 
    storageType: {{ $msgStorageType }}
    storageName: {{ $msgStorageName }}
    storageSize: {{ $msgStorageSize }}
  logs: 
    storageType: {{ $logStorageType }}
    storageName: {{ $logStorageName }}
    storageSize: {{ $logStorageSize }}
  skipRedeploy: "{{ .Values.apd.skipRedeploy }}"
  allowNodeSkew: "{{ .Values.apd.allowNodeSkew | default $allowNodeSkew }}"
  allowZoneSkew: "{{ .Values.apd.allowZoneSkew | default $allowZoneSkew }}"
  # Allow some component specific overrides
  zoo:
    serviceAccount: {{ .Values.apd.zoo.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
  bookie:
    serviceAccount: {{ .Values.apd.bookie.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
  broker:
    serviceAccount: {{ .Values.apd.broker.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
  proxy:
    serviceAccount: {{ .Values.apd.proxy.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
  recovery:
    serviceAccount: {{ .Values.apd.recovery.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
  toolset:
    serviceAccount: {{ .Values.apd.toolset.serviceAccount | default $dpParams.dp.serviceAccount }}
    resources: {}
{{ end }}
