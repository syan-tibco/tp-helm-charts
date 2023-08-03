
{{/*
MSG DP EMS-on-FTL Helpers
*/}}

{{/*
need.msg.ems.params
*/}}
{{ define "need.msg.ems.params" }}
{{-  $dpParams := include "need.msg.dp.params" . | fromYaml -}}
{{-  $emsDefaultFullImage := printf "%s%smsg-ems-all:10.2.1-5" $dpParams.dp.registry $dpParams.dp.repo -}}
{{ include "need.msg.dp.params" . }}
ems:
  name: {{ ternary .Release.Name .Values.ems.name ( not .Values.ems.name ) }}
  replicas: 3
  isLeader: "http://localhost:9011/isReady"
  allowNodeSkew: "true"
  allowZoneSkew: "true"
  {{- $sizing := "small" -}}
  {{- $use := "dev" -}}
  {{- $storageSize := "4Gi" -}}
  {{- $cpuReq := "0.3" -}}
  {{- $cpuLim := "3" -}}
  {{- $memReq := "1Gi" -}}
  {{- $memLim := "4Gi" -}}
  {{ if .Values.ems }}
  stores: {{ ternary "ftl" .Values.ems.stores ( not .Values.ems.stores ) }}
  image: {{ ternary $emsDefaultFullImage .Values.ems.image ( not .Values.ems.image ) }}
  quorumStrategy: {{ ternary "quorum-based" .Values.ems.quorumStrategy ( not .Values.ems.quorumStrategy ) }}
  {{- $sizing = ternary  "small" .Values.ems.sizing ( not  .Values.ems.sizing ) -}}
  {{- $use = ternary  "dev" .Values.ems.use ( not  .Values.ems.use ) -}}
  {{- if eq $sizing "medium" -}}
    {{- $storageSize = "25Gi" -}}
    {{- $cpuReq = "1.0" -}}
    {{- $cpuLim = "5" -}}
    {{- $memReq = "2Gi" -}}
    {{- $memLim = "8Gi" -}}
  {{- else if eq $sizing "large" -}}
    {{- $storageSize = "50Gi" -}}
    {{- $cpuReq = "2" -}}
    {{- $cpuLim = "8" -}}
    {{- $memReq = "8Gi" -}}
    {{- $memLim = "20Gi" -}}
  {{ end }}
  {{- if eq $use "production" -}}
    {{- $cpuReq = $cpuLim -}}
    {{- $memReq = $memLim -}}
  {{ end }}
  sizing: {{ $sizing }}
  use: {{ $use }}
  msgData: 
    {{ if .Values.ems.msgData }}
    storageType: {{ ternary  "storageClass" .Values.ems.msgData.storageType ( not  .Values.ems.msgData.storageType ) }}
    storageName: {{ ternary  "hostpath" .Values.ems.msgData.storageName ( not  .Values.ems.msgData.storageName ) }}
    storageSize: {{ ternary  $storageSize .Values.ems.msgData.storageSize ( not  .Values.ems.msgData.storageSize ) }}
    {{ else }}
    storageType: storageClass
    storageName: hostpath
    storageSize: {{ $storageSize }}
    {{ end }}
  logs: 
    {{ if .Values.ems.logs }}
    storageType: {{ ternary  "useMsgData" .Values.ems.logs.storageType ( not  .Values.ems.logs.storageType ) }}
    storageName: {{ ternary  "none" .Values.ems.logs.storageName ( not  .Values.ems.logs.storageName ) }}
    storageSize: {{ ternary  $storageSize .Values.ems.logs.storageSize ( not  .Values.ems.logs.storageSize ) }}
    {{ else }}
    storageType: useMsgData
    storageName: none
    storageSize: {{ $storageSize }}
    {{ end }}
  resources:
    {{ if .Values.ems.resources }}
    {{ .Values.ems.resources | indent 4 }}
    {{ else }}
  {{ if ne $use "dev" }}
    requests:
      memory: {{ $memReq }}
      cpu: {{ $cpuReq }}
    limits:
      memory: {{ $memLim }}
      cpu: {{ $cpuLim }}
  {{ end }}
    {{ end }}
  {{ else }}
  name: {{ .Release.Name }}
  image: {{ $emsDefaultFullImage }}
  stores: ftl
  quorumStrategy: "quorum-based"
  sizing: small
  use: {{ $use }}
  msgData: 
    storageType: storageClass
    storageName: hostpath
    storageSize: "1Gi"
  logs: 
    storageType: useMsgData
    storageName: none
    storageSize: "1Gi"
  resources:
    {{ if ne $use "dev" }}
    requests:
      memory: {{ $memReq }}
      cpu: {{ $cpuReq }}
    limits:
      memory: {{ $memLim }}
      cpu: {{ $cpuLim }}
    {{ end }}
  {{ end }}
{{ end }}
