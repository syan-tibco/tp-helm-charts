export DP_RESOURCE_GROUP=dp-resource-group
export DP_CLUSTER_NAME=dp-cluster
export AZURE_REGION=eastus
export AUTHORIZED_IP="103.243.236.10"
export VNET_CIDR="10.224.0.0/12"

# create resource group
az group create --location "${AZURE_REGION}" --name "${DP_RESOURCE_GROUP}"

echo "start to create AKS: ${DP_RESOURCE_GROUP}/${DP_CLUSTER_NAME}"
# create aks cluster
az aks create -g "${DP_RESOURCE_GROUP}" -n "${DP_CLUSTER_NAME}" \
  --enable-managed-identity \
  --node-count 2 \
  --enable-addons monitoring \
  --enable-msi-auth-for-monitoring \
  --generate-ssh-keys \
  --api-server-authorized-ip-ranges "${AUTHORIZED_IP}" \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --network-plugin azure \
  --kubernetes-version "1.28.0" \
  --outbound-type managedNATGateway
echo "finished creating AKS"