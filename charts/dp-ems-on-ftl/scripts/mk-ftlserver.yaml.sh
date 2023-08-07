#!/bin/bash

# Copyright (c) 2023 Cloud Software Group, Inc. All Rights Reserved. Confidential and Proprietary.

outfile=${1:-ftlserver.yml}
srvBase="${MY_POD_NAME%-*}"
svcname="${MY_SVC_NAME:-$srvBase}"
namespace=$MY_NAMESPACE
ftlport="${FTL_PORT:-443}"
podData="/data"
podData="/data"
# loglevel=${FTL_LOGLEVEL:-"info;quorum:debug"}
loglevel=${FTL_LOGLEVEL:-"info"}
cat - <<EOF > $outfile
globals:
  loglevel: "$loglevel"
  # Add internal.address for FTL-6.6 compatibility
  # internal.address: "*:${ftlport}"
  core.servers:
    ${srvBase}-0: "${srvBase}-0.${svcname}.${namespace}.svc:${ftlport}"
    ${srvBase}-1: "${srvBase}-1.${svcname}.${namespace}.svc:${ftlport}"
    ${srvBase}-2: "${srvBase}-2.${svcname}.${namespace}.svc:${ftlport}"
services:
  realm:
    default.cluster.disk.swap: true
servers:
  ${srvBase}-0:
    - tibemsd:
        exepath: /opt/tibco/ems/bin/tibemsd
        -listens: tcp://0.0.0.0:9010
        -health_check_listen: http://0.0.0.0:9011
        -store: "$podData/emsdata"
        -config_wait:
    - realm:
        data: "$podData/realm"
    - persistence:
        name: default_${srvBase}-0
        data: "$podData/ftldata"
        swapdir: "$podData/swap"
  ${srvBase}-1:
    - tibemsd:
        exepath: /opt/tibco/ems/bin/tibemsd
        -listens: tcp://0.0.0.0:9010
        -health_check_listen: http://0.0.0.0:9011
        -store: "$podData/emsdata"
        -config_wait:
    - realm:
        data: "$podData/realm"
    - persistence:
        name: default_${srvBase}-1
        data: "$podData/ftldata"
        swapdir: "$podData/swap"
  ${srvBase}-2:
    - tibemsd:
        exepath: /opt/tibco/ems/bin/tibemsd
        -listens: tcp://0.0.0.0:9010
        -health_check_listen: http://0.0.0.0:9011
        -store: "$podData/emsdata"
        -standby_only:
        -config_wait:
    - realm:
        data: "$podData/realm"
    - persistence:
        name: default_${srvBase}-2
        data: "$podData/ftldata"
        swapdir: "$podData/swap"
EOF