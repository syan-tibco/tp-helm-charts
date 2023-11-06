#!/bin/bash

export DP_RESOURCE_GROUP=${1:-dp-resource-group}
export STORAGE_ACCOUNT_NAME=${2:-templatestorageaccount3}

# need to output empty string otherwise will output null
PVC_LIST=$(kubectl get pv -o jsonpath='{range .items[?(@.spec.csi.driver=="file.csi.azure.com")]}{.metadata.name}{"\n"}{end}')

echo "deleting all ingress objects"
kubectl delete ingress -A --all

echo "sleep 2 minutes"
sleep 120

echo "deleting all installed charts with no layer labels"
helm ls --selector '!layer' -a -A -o json | jq -r '.[] | "\(.name) \(.namespace)"' | while read -r line; do
  release=$(echo ${line} | awk '{print $1}')
  namespace=$(echo ${line} | awk '{print $2}')
  helm uninstall -n "${namespace}" "${release}"
done

for (( _chart_layer=2 ; _chart_layer>=0 ; _chart_layer-- ));
do
  echo "deleting all installed charts with layer ${_chart_layer} labels"
  helm ls --selector "layer=${_chart_layer}" -a -A -o json | jq -r '.[] | "\(.name) \(.namespace)"' | while read -r line; do
    release=$(echo ${line} | awk '{print $1}')
    namespace=$(echo ${line} | awk '{print $2}')
    helm uninstall -n "${namespace}" "${release}"
  done
done

echo "deleting resource group"
az group delete -n ${DP_CLUSTER_NAME} -y

echo "deleting file shares"
while read -r line
  do
    echo "deleting ${line} in storage account ${STORAGE_ACCOUNT_NAME}"
    az storage share delete --name ${line} --delete-snapshots "include" --account-name ${STORAGE_ACCOUNT_NAME}
  done <<< ${PVC_LIST}