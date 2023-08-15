#!/bin/bash
# Copyright (c) 2023 Cloud Software Group, Inc. All Rights Reserved. Confidential and Proprietary.

outfile=${1:-output.conf}
if [ "$SYSTEM_WHERE" = 'aws' ] ; then 
cat - <<EOF > $outfile
[OUTPUT]
    Name es
    Match routable
    Host ${SYSTEM_LOGGER_HOST}
    Port ${SYSTEM_LOGGER_PORT}
    Index ${TCM_LOGGER_INDEX}
    tls ${TCM_TLS_FLAG}
    tls.verify ${TCM_TLSV_FLAG}
    HTTP_User ${TCM_LOGGER_USER}
    HTTP_Passwd ${TCM_LOGGER_PASSWD}
    Trace_Output Off
    Trace_Error On
EOF
else
cat - <<EOF > $outfile
[OUTPUT]
    Name stdout
    Match routable
EOF
fi
