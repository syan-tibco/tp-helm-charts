
{{/*
MSG DP Common Helpers
*/}}

{{/*
need.msg.dp.params
*/}}
{{ define "need.msg.dp.params" }}
dp:
  # Use TCM testbed defaults for now
  uid: 0
  gid: 0
  where: "local"
  {{- $name := "dp-noname" -}}
  {{- $pullSecret := "cic2-tcm-ghcr-secret" -}}
  {{- $registry := "ghcr.io/" -}}
  {{- $repo := "tibco/msg-platform-cicd/" -}}
  {{- $pullPolicy := "IfNotPresent" -}}
  {{- $serviceAccount := "provisioner" -}}
  {{ if .Values.global }}
    {{ if .Values.global.cp }}
      {{ $name = ternary  $name .Values.global.cp.name ( not  .Values.global.cp.name ) }}
      {{ $pullSecret = ternary  $pullSecret  .Values.global.cp.pullSecret ( not  .Values.global.cp.pullSecret ) }}
      {{ $registry = ternary  $registry  .Values.global.cp.registry ( not  .Values.global.cp.registry ) }}
      {{ $repo = ternary  $repo  .Values.global.cp.repo ( not  .Values.global.cp.repo ) }}
      {{ $pullPolicy = ternary  $pullPolicy  .Values.global.cp.pullPolicy ( not  .Values.global.cp.pullPolicy ) }}
      {{ $serviceAccount = ternary  $serviceAccount  .Values.global.cp.serviceAccount ( not  .Values.global.cp.serviceAccount ) }}
    {{ end }}
  {{ end }}
  {{ if .Values.dp }}
    {{ $name = ternary  $name  .Values.dp.name ( not  .Values.dp.name ) }}
    {{ $pullSecret = ternary  $pullSecret  .Values.dp.pullSecret ( not  .Values.dp.pullSecret ) }}
    {{ $registry = ternary  $registry  .Values.dp.registry ( not  .Values.dp.registry ) }}
    {{ $repo = ternary  $repo  .Values.dp.repo ( not  .Values.dp.repo ) }}
    {{ $pullPolicy = ternary  $pullPolicy  .Values.dp.pullPolicy ( not  .Values.dp.pullPolicy ) }}
    {{ $serviceAccount = ternary  $serviceAccount  .Values.dp.serviceAccount ( not  .Values.dp.serviceAccount ) }}
  {{ end }}
  name: {{ $name }}
  pullSecret: {{ $pullSecret }}
  registry: {{ $registry }}
  repo: {{ $repo }}
  pullPolicy: {{ $pullPolicy }}
  serviceAccount: {{ $serviceAccount }}
{{ end }}

{{/*
msg.dp.mon.annotations adds
note: tib-msg-stsname will be added directly in statefulset charts, as it needs to be the pod match label
*/}}
{{- define "msg.dp.mon.annotations" }}
platform.tibco.com/workload-type: "capability-service"
platform.tibco.com/dataplane-id: "{{ .Values.global.cp.dataplaneId | default "local-dp" }}"
platform.tibco.com/capability-instance-id: "{{ .Values.global.cp.instanceId | default "local-cp" }}"
platform.tibco.com/leader-endpoint: "{{ .Values.global.cp.instanceId | default "local-cp" }}"
{{- end }}

{{/*
msg.labels.standard prints the standard Helm labels.
note: tib-msg-stsname will be added directly in statefulset charts, as it needs to be the pod match label
*/}}
{{- define "msg.dp.labels" }}
tib-dp-release: {{ .Release.Name | quote }}
tib-dp-chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
tib-dp-workload-type: "capability-service"
tib-dp-dataplane-id: "{{ .Values.global.cp.dataplaneId | default "local-dp" }}"
tib-dp-capability-instance-id: "{{ .Values.global.cp.instanceId | default "local-cp" }}"
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
