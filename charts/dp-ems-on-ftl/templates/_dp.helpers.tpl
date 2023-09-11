
{{/*
MSG DP Common Helpers
*/}}

{{/*
need.msg.dp.params
*/}}
{{ define "need.msg.dp.params" }}
dp:
  # Reference for global.cp attributes : 
  #   https://confluence.tibco.com/x/uoBUEQ
  # Use TCM testbed defaults for now
  {{- $where := "local" -}}
  {{- $name := "dp-noname" -}}
  {{- $pullSecret := "cic2-tcm-ghcr-secret" -}}
  {{- $registry := "ghcr.io" -}}
  {{- $repo := "tibco/msg-platform-cicd" -}}
  {{- $pullPolicy := "IfNotPresent" -}}
  {{- $serviceAccount := "provisioner" -}}
  {{- $scSharedName := "none" -}}
  # These 4 are currently unused!
  {{- $cpHostname := "no-cpHostname" -}}
  {{- $instanceId := "no-instanceId" -}}
  {{- $environmentType := "no-environmentType" -}}
  {{- $subscriptionId := "no-subscriptionId" -}}
  {{ if .Values.global }}
    {{ if .Values.global.cp }}
      {{ $name = ternary  $name .Values.global.cp.dataplaneId ( not  .Values.global.cp.dataplaneId ) }}
      {{ $serviceAccount = ternary  $serviceAccount  .Values.global.cp.serviceAccount ( not  .Values.global.cp.serviceAccount ) }}
      {{ $pullPolicy = ternary  $pullPolicy  .Values.global.cp.pullPolicy ( not  .Values.global.cp.pullPolicy ) }}
        {{ if .Values.global.cp.containerRegistry }}
          {{ $registry = ternary  $registry  .Values.global.cp.containerRegistry.url ( not  .Values.global.cp.containerRegistry.url ) }}
          {{ $repo = ternary  "msg-platform-cicd"  .Values.global.cp.containerRegistry.repo ( not  .Values.global.cp.containerRegistry.repo ) }}
        {{ end }}
      {{ $cpHostname = ternary  $cpHostname .Values.global.cp.cpHostname ( not  .Values.global.cp.cpHostname ) }}
      {{ $instanceId = ternary  $instanceId .Values.global.cp.instanceId ( not  .Values.global.cp.instanceId ) }}
      {{ $environmentType = ternary  $environmentType .Values.global.cp.environmentType ( not  .Values.global.cp.environmentType ) }}
      {{ $subscriptionId = ternary  $subscriptionId .Values.global.cp.subscriptionId ( not  .Values.global.cp.subscriptionId ) }}
        {{ if .Values.global.cp.resources }}
        {{ if .Values.global.cp.resources.serviceaccount }}
        {{ if .Values.global.cp.resources.serviceaccount.serviceAccountName }}
          {{ $serviceAccount =  .Values.global.cp.resources.serviceaccount.serviceAccountName | default  $serviceAccount }}
        {{ end }}
        {{ end }}
        {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.ems }}
    {{ if .Values.ems.logs }}
      {{ if .Values.ems.logs.storageType }}
      {{ if eq "sharedStorageClass" .Values.ems.logs.storageType }}
        {{ $scSharedName = .Values.ems.logs.storageName }}
      {{ end }}
      {{ end }}
    {{ end }}
    {{ if .Values.ems.msgData }}
      {{ if .Values.ems.msgData.storageType }}
      {{ if eq "sharedStorageClass" .Values.ems.msgData.storageType }}
        {{ $scSharedName = .Values.ems.msgData.storageName }}
      {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.dp }}
    {{ $name = ternary  $name  .Values.dp.name ( not  .Values.dp.name ) }}
    {{ $pullSecret = ternary  $pullSecret  .Values.dp.pullSecret ( not  .Values.dp.pullSecret ) }}
    {{ $registry = ternary  $registry  .Values.dp.registry ( not  .Values.dp.registry ) }}
    {{ $repo = ternary  $repo  .Values.dp.repo ( not  .Values.dp.repo ) }}
    {{ $pullPolicy = ternary  $pullPolicy  .Values.dp.pullPolicy ( not  .Values.dp.pullPolicy ) }}
    {{ $serviceAccount = ternary  $serviceAccount  .Values.dp.serviceAccount ( not  .Values.dp.serviceAccount ) }}
    {{ $scSharedName = ternary  $scSharedName  .Values.dp.scSharedName ( not  .Values.dp.scSharedName ) }}
  {{ end }}
  uid: 0
  gid: 0
  where: {{ $where }}
  name: {{ $name }}
  pullSecret: {{ $pullSecret }}
  registry: {{ $registry }}
  repo: {{ $repo }}
  pullPolicy: {{ $pullPolicy }}
  serviceAccount: {{ $serviceAccount }}
  cpHostname: {{ $cpHostname }}
  instanceId: {{ $instanceId }}
  environmentType: {{ $environmentType }}
  subscriptionId: {{ $subscriptionId }}
  scSharedName: {{ $scSharedName }}
{{ end }}

{{/*
msg.dp.mon.annotations adds
note: tib-msg-stsname will be added directly in statefulset charts, as it needs to be the pod match label
*/}}
{{- define "msg.dp.mon.annotations" }}
platform.tibco.com/workload-type: "capability-service"
platform.tibco.com/dataplane-id: "{{ .Values.global.cp.dataplaneId | default "local-dp" }}"
platform.tibco.com/capability-instance-id: "{{ .Values.global.cp.instanceId | default "local-cp" }}"
# platform.tibco.com/leader-endpoint: "{{ .Values.global.cp.instanceId | default "local-cp" }}"
{{- end }}

{{/*
msg.labels.standard prints the standard Helm labels.
note: tib-msg-stsname will be added directly in statefulset charts, as it needs to be the pod match label
*/}}
{{- define "msg.dp.labels" }}
tib-dp-release: {{ .Release.Name | quote }}
tib-dp-msgbuild: "1.0.0.8"
tib-dp-chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
tib-dp-workload-type: "capability-service"
tib-dp-dataplane-id: "{{ .Values.global.cp.dataplaneId | default "local-dp" }}"
tib-dp-capability-instance-id: "{{ .Values.global.cp.instanceId | default .Release.Name }}"
platform.tibco.com/workload-type: "capability-service"
platfrom.tibco.com/capability-instance-id: "{{ .Values.global.cp.instanceId | default .Release.Name }}"
platfrom.tibco.com/dataplane-id: "{{ .Values.global.cp.dataplaneId | default "local-dp" }}"
{{- end }}

{{/*
msg.envPodRefs - expand a list of <name: field> for use in a env: section
*/}}
{{- define "msg.envPodRefs" }}
# START-OF- EXPANDED PodRef List
{{- range $key, $val := . }}
- name: {{ $key | quote }}
  valueFrom:
    fieldRef:
      fieldPath: {{ $val }}
{{- end }}
# END-OF-EXPANDED PodRef List
{{- end }}

{{/*
msg.envStdPodRefs - generate a list of standard <name: field> for use in a env: section
*/}}
{{- define "msg.envStdPodRefs" }}
{{- $stdRefs := (dict "MY_POD_NAME" "metadata.name" "MY_NAMESPACE" "metadata.namespace" "MY_POD_IP" "status.podIP" "MY_NODE_NAME" "spec.nodeName" "MY_NODE_IP" "status.hostIP" "MY_SA_NAME" "spec.serviceAccountName"  ) -}}
{{ include "msg.envPodRefs" $stdRefs }}
{{- end }}
