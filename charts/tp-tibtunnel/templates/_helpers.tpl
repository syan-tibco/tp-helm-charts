{{/* Generate tibtunnel configure command using values params. Ex: tp-tibtunnel configure --tibcoDataPlaneId abcd -a accessKey --config-dir /opt/config/tibtunnel */}}
{{- define "tp-tibtunnel.helpers.command.configure" -}}
{{- $profile := printf "%s%s" (ternary "--profile " "" (ne .Values.configure.profile "")) .Values.configure.profile  -}}
{{- $dataPlaneId := printf "%s%s" (ternary "--tibcoDataPlaneId " "" (ne .Values.global.tibco.dataPlaneId "")) .Values.global.tibco.dataPlaneId -}}
{{-  $accessKey := printf "%s%s" (ternary "-a " "" (ne .Values.configure.accessKey "")) .Values.configure.accessKey -}}
tp-tibtunnel configure {{ $profile }} {{ $dataPlaneId }} {{ $accessKey }} --config-dir {{.Values.configDir}}
{{- end -}}

{{/* Generate tibtunnel connect command using values params. Ex: tp-tibtunnel connect -d --config-dir /etc/config/tibtunnel --data-ack-mode=false --remote-debug --network-check-url */}}
{{- define "tp-tibtunnel.helpers.command.connect" -}}
{{- $profile := printf "%s%s" (ternary "--profile " "" (ne .Values.connect.profile "")) .Values.connect.profile  -}}
{{- $debug := ternary "-d" "" .Values.connect.debug  -}}
{{- $payload := ternary "--payload" "" .Values.connect.payload -}}
{{- $dataChunkSize := printf "%s%s" (ternary "--data-chunk-size " "" ( ne (.Values.connect.dataChunkSize| toString ) "")) (.Values.connect.dataChunkSize|toString) -}}
{{- $dataAckMode := printf "%s%t" "--data-ack-mode=" .Values.connect.dataAckMode -}}
{{- $remoteDebug := ternary "--remote-debug" "" .Values.connect.remoteDebug -}}
{{- $logFile := printf "%s%s" (ternary "--log-file " "" (ne .Values.connect.logFile "")) .Values.connect.logFile }}
{{- $networkCheckUrl := printf "%s%s" (ternary "--network-check-url " "" (ne .Values.connect.networkCheckUrl "")) .Values.connect.networkCheckUrl }}
{{- $infiniteRetries := ternary "--infinite-retries" "" .Values.connect.infiniteRetries -}}
tp-tibtunnel connect {{ $debug }} --config-dir {{.Values.configDir}} {{ $payload }} {{ $dataChunkSize }} {{ $dataAckMode }} {{ $remoteDebug }}  {{ $logFile }} {{ $profile }} {{ $networkCheckUrl }} {{ $infiniteRetries }} -s {{ tpl .Values.connect.onPremHost .}}:{{.Values.connect.onPremPort}} {{ .Values.connect.url }}
{{- end -}}