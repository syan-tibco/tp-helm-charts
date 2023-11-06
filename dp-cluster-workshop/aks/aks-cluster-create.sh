#!/bin/bash
set +x

export SUBSCRIPTION_ID="14669e18-e772-4744-bf93-72f677ccb9aa"
export TENANT_ID="cde6fa59-abb3-4971-be01-2443c417cbda"
export DP_RESOURCE_GROUP="dp-resource-group"
export DP_CLUSTER_NAME="dp-cluster"
export AZURE_REGION="eastus"
export USER_ASSIGNED_IDENTITY_NAME="dp-cluster-identity"
export AUTHORIZED_IP="103.243.236.10/32,160.101.0.10/32,160.101.128.1/32"  # TIBCO Offices VPN
export VNET_NAME="dp-cluster-vnet"
export VNET_CIDR="10.4.0.0/16"
export AKS_SUBNET_NAME="aks-subnet"
export AKS_SUBNET_CIDR="10.4.0.0/20"
export APPLICATION_GW_SUBNET_NAME="appgw-subnet"
export APPLICATION_GW_SUBNET_CIDR="10.4.17.0/24"
export NAT_GW_NAME="nat-gateway"
export NAT_GW_SUBNET_NAME="natgw-subnet"
export NAT_GW_SUBNET_CIDR="10.4.18.0/27"
export PUBLIC_IP_NAME="public-ip"


# add your public ip
MY_PUBLIC_IP=$(curl https://ipinfo.io/ip)
export AUTHORIZED_IP="${AUTHORIZED_IP},${MY_PUBLIC_IP}"

# create resource group
az group create --location "${AZURE_REGION}" --name "${DP_RESOURCE_GROUP}"

# create user-assigned identity
az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${DP_RESOURCE_GROUP}"
export USER_ASSIGNED_ID="/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${DP_RESOURCE_GROUP}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${USER_ASSIGNED_IDENTITY_NAME}"
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -otsv)"
export USER_ASSIGNED_PRINCIPAL_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'principalId' -otsv)"
export USER_ASSIGNED_PRINCIPAL_ID="$(az identity show --resource-group "${DP_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'principalId' -otsv)"

# create public ip
az network public-ip create -g "${DP_RESOURCE_GROUP}" -n ${PUBLIC_IP_NAME} --sku "Standard" --allocation-method "Static"
export PUBLIC_IP_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/publicIPAddresses/${PUBLIC_IP_NAME}"

# create nat gateway
az network nat gateway create --resource-group "${DP_RESOURCE_GROUP}" --name "${NAT_GW_NAME}" --public-ip-addresses "${PUBLIC_IP_ID}"
export NAT_GW_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/natGateways/${NAT_GW_NAME}"

# append public ip
export NAT_GW_PUBLIC_IP=$(az network public-ip show -g ${DP_RESOURCE_GROUP} -n ${PUBLIC_IP_NAME}  --query 'ipAddress' -otsv)
export AUTHORIZED_IP="${AUTHORIZED_IP},${NAT_GW_PUBLIC_IP}"

# create virtual network
az network vnet create -g "${DP_RESOURCE_GROUP}" -n "${VNET_NAME}" --address-prefix "${VNET_CIDR}" 

# create application gateway subnets
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${APPLICATION_GW_SUBNET_NAME}" --address-prefixes "${APPLICATION_GW_SUBNET_CIDR}"
export APPLICATION_GW_SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${APPLICATION_GW_SUBNET_NAME}"

# create aks subnet
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${AKS_SUBNET_NAME}" --address-prefixes "${AKS_SUBNET_CIDR}" --nat-gateway "${NAT_GW_ID}"
export AKS_VNET_SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${AKS_SUBNET_NAME}"

# create nat gateway subnet
az network vnet subnet create -g ${DP_RESOURCE_GROUP} --vnet-name "${VNET_NAME}" -n "${NAT_GW_SUBNET_NAME}" --address-prefixes "${NAT_GW_SUBNET_CIDR}" --nat-gateway "${NAT_GW_ID}"
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
echo "finished creating AKS"