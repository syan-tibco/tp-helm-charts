#!/bin/bash
set +x

function verify_error() {
  _exit_code="${1}"
  _command="${2}"
  [ "${_exit_code}" -eq "0" ] || { echo "Failed to run the az command to create ${_command}"; exit ${_exit_code}; }
}

# add your public ip
MY_PUBLIC_IP=$(curl https://ipinfo.io/ip)
if [ -n "${AUTHORIZED_IP}" ]; then
  export AUTHORIZED_IP="${AUTHORIZED_IP},${MY_PUBLIC_IP}"
else
  export AUTHORIZED_IP="${MY_PUBLIC_IP}"
fi

# create resource group
az group create --location "${AZURE_REGION}" --name "${DP_RESOURCE_GROUP}"
_ret=$?
verify_error "${_ret}" "resource_group"

# create user-assigned identity
az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${DP_RESOURCE_GROUP}"
_ret=$?
verify_error "${_ret}" "identity"
export USER_ASSIGNED_ID="/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${DP_RESOURCE_GROUP}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${USER_ASSIGNED_IDENTITY_NAME}"
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -otsv)"
export USER_ASSIGNED_PRINCIPAL_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'principalId' -otsv)"
export USER_ASSIGNED_PRINCIPAL_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'principalId' -otsv)"

# create public ip
az network public-ip create -g "${DP_RESOURCE_GROUP}" -n ${PUBLIC_IP_NAME} --sku "Standard" --allocation-method "Static"
_ret=$?
verify_error "${_ret}" "public_ip"
export PUBLIC_IP_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/publicIPAddresses/${PUBLIC_IP_NAME}"

# create nat gateway
az network nat gateway create --resource-group "${DP_RESOURCE_GROUP}" --name "${NAT_GW_NAME}" --public-ip-addresses "${PUBLIC_IP_ID}"
_ret=$?
verify_error "${_ret}" "nat_gateway"
export NAT_GW_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/natGateways/${NAT_GW_NAME}"

# append public ip
export NAT_GW_PUBLIC_IP=$(az network public-ip show -g ${DP_RESOURCE_GROUP} -n ${PUBLIC_IP_NAME}  --query 'ipAddress' -otsv)
export AUTHORIZED_IP="${AUTHORIZED_IP},${NAT_GW_PUBLIC_IP}"

# create virtual network
az network vnet create -g "${DP_RESOURCE_GROUP}" -n "${VNET_NAME}" --address-prefix "${VNET_CIDR}" 
_ret=$?
verify_error "${_ret}" "VNet"

# create application gateway subnets
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${APPLICATION_GW_SUBNET_NAME}" --address-prefixes "${APPLICATION_GW_SUBNET_CIDR}"
_ret=$?
verify_error "${_ret}" "application_gateway_subnet"
export APPLICATION_GW_SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${APPLICATION_GW_SUBNET_NAME}"

# create aks subnet
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${AKS_SUBNET_NAME}" --address-prefixes "${AKS_SUBNET_CIDR}" --nat-gateway "${NAT_GW_ID}"
_ret=$?
verify_error "${_ret}" "aks_subnet"
export AKS_VNET_SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${AKS_SUBNET_NAME}"

# create nat gateway subnet
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${NAT_GW_SUBNET_NAME}" --address-prefixes "${NAT_GW_SUBNET_CIDR}" --nat-gateway "${NAT_GW_ID}"
_ret=$?
verify_error "${_ret}" "nat_gateway_subnet"
export NAT_GW_VNET_SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${NAT_GW_SUBNET_NAME}"

# create aks cluster
echo "start to create AKS: ${DP_RESOURCE_GROUP}/${DP_CLUSTER_NAME}"
az aks create -g "${DP_RESOURCE_GROUP}" -n "${DP_CLUSTER_NAME}" \
  --node-count 3 \
  --enable-addons ingress-appgw \
  --enable-msi-auth-for-monitoring false \
  --generate-ssh-keys \
  --api-server-authorized-ip-ranges "${AUTHORIZED_IP}" \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --network-plugin azure \
  --kubernetes-version "1.28.0" \
  --outbound-type userAssignedNATGateway \
  --appgw-name gateway \
  --vnet-subnet-id "${AKS_VNET_SUBNET_ID}" \
  --appgw-subnet-id "${APPLICATION_GW_SUBNET_ID}" \
  --assign-identity "${USER_ASSIGNED_ID}" \
  --assign-kubelet-identity "${USER_ASSIGNED_ID}"
_ret=$?
verify_error "${_ret}" "cluster"

echo "finished creating AKS"