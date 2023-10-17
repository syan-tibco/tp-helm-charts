#!/bin/bash
# Copyright (c) 2023 Cloud Software Group, Inc. All Rights Reserved. Confidential and Proprietary.

base="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"
cmd="${0##*/}"

usage="
    $cmd [options] [relname] -- deploy this chart to default \$DP_ENV.kconf namespace
    -r <relname>    : explicitly set \$MY_RELEASE
    -e <emsname>    : explicitly set \$EMS_NAME
    -v <file>       : add a helm values file of setting
    -s <key=value>  : add a helm setting
    -k <kubeconfing> : override the default kubeconfig file
    -n <namespace>  : override the default namespace
By default:
    \$EMS_NAME = \$MY_RELEASE if not set
"
function die { echo "$*" ; exit 1 ; }

source=/net/nperf14/k8/share/jk-msgdp/USERS/dmiller/src/msg-platform-cicd
build=/net/nperf14/k8/share/jk-msgdp/USERS/dmiller/dp-build
chartdir="$base"
kconf=""
helm_opts=()
MY_NS_OPT=

while getopts "e:s:v:n:k:h" opts; do
    case $opts in
        r) export MY_RELEASE="${OPTARG}" ;;
        e) export EMS_NAME="${OPTARG}" ;;
        v) helm_opts+="--values=${OPTARG} " ;;
        s) helm_opts+="--set=${OPTARG} " ;;
        n) helm_opts+="-n=${OPTARG} " ; export MY_NS_OPT="-n=$OPTARG" ;;
        k) kconf="${OPTARG}" ;;
        h) echo "$usage" ; exit 0 ;;
        *) echo "$usage" ; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# set -x
[ -n "$1" ] && export MY_RELEASE="$1"
[ -z "$EMS_NAME" ] && [ -n "$1" ] && export EMS_NAME="$1"

# Look for a Kubeconfig
if [ -n "$kconf" ] ; then 
    export KUBECONFIG="$kconf"
    [ ! -f "$kconf" ] && [ -f "$HOME/.kube/$kconf" ] && export KUBECONFIG=$HOME/.kube/$kconf
elif [ -n "$DP_ENV" ] ; then
    for kconf in $DP_ENV.kconf tcm-qa-$DP_ENV.kconf tcm-ca-$DP_ENV.kconf $DP_ENV.qa.kubeconfig ; do 
        [ -f "$HOME/.kube/$kconf" ] && export KUBECONFIG=$HOME/.kube/$kconf && break
    done
fi
# Lookup real release name if using $EMS_NAME
if [ -z "$MY_RELEASE" ] && [ -n "$EMS_NAME" ] ; then
    export MY_RELEASE="$(kubectl get $MY_NS_OPT cm/$EMS_NAME-clients -o=jsonpath='{.metadata.labels.tib-dp-release}' )"
    [ -z "$MY_RELEASE" ] && echo " -- ERROR: unable to get release name from cm/$EMS_NAME-clients." && exit 1
fi
relname="$MY_RELEASE"

helm get values $MY_NS_OPT $relname > $relname.values.yaml || die "Error fetching values from $relname"
echo "#+: " helm upgrade $MY_RELEASE $chartdir --values=$relname.values.yaml ${helm_opts[*]} 
helm upgrade $MY_RELEASE $chartdir --values=$relname.values.yaml ${helm_opts[*]} 
