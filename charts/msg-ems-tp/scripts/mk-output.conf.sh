#!/bin/bash
# Copyright (c) 2023 Cloud Software Group, Inc. All Rights Reserved. Confidential and Proprietary.

outfile=${1:-output.conf}
cat - <<EOF > $outfile
[OUTPUT]
    Name                 opentelemetry
    Match                dp.*
    Host                 otel-services.${MY_NAMESPACE}.svc.cluster.local
    Port                 4318
    Logs_uri             /v1/logs
    Log_response_payload True
    Tls                  Off
    Tls.verify           Off
EOF

outfile=${1:-output-stdout.conf}
cat - <<EOF > $outfile
[OUTPUT]
    Name stdout
    Match dp.routable
EOF
