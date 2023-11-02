set -x

export SUBSCRIPTION_ID="14669e18-e772-4744-bf93-72f677ccb9aa"
export TENANT_ID="cde6fa59-abb3-4971-be01-2443c417cbda"
export DP_RESOURCE_GROUP="dp-resource-group"
export DNS_RESOURCE_GROUP="cic-dns"
export DP_CLUSTER_NAME="dp-cluster"
export AZURE_REGION="eastus"
export USER_ASSIGNED_IDENTITY_NAME="dp-cluster-identity"
export ATTACH_TIBCO_ACR=true

export USER_ASSIGNED_IDENTITY_CLIENT_ID=$(az aks show --resource-group "${DP_RESOURCE_GROUP}" --name "${DP_CLUSTER_NAME}" --query "identityProfile.kubeletidentity.clientId" --output tsv)
export USER_ASSIGNED_IDENTITY_PRINCIPAL_ID=$(az aks show --resource-group "${DP_RESOURCE_GROUP}" --name "${DP_CLUSTER_NAME}" --query "identityProfile.kubeletidentity.objectId" --output tsv)
export USER_ASSIGNED_IDENTITY_OBJECT_ID="${USER_ASSIGNED_IDENTITY_PRINCIPAL_ID}"

# add dns zone contributor permission
az role assignment create \
  --role "DNS Zone Contributor" \
  --assignee-object-id "${USER_ASSIGNED_IDENTITY_OBJECT_ID}" \
  --assignee-principal-type "ServicePrincipal" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DNS_RESOURCE_GROUP}"


if [ "${ATTACH_TIBCO_ACR}" == "true" ]; then
  ## other variables
  _master_sub="520d9f10-9713-409c-b8bc-10345c9c01eb"
  _acr_name="troposerv"
  _container_rg="container_registry"

  # add acr pull permission
  az role assignment create --assignee-object-id "${USER_ASSIGNED_IDENTITY_OBJECT_ID}" \
    --assignee-principal-type "ServicePrincipal" --role "AcrPull" \
    --scope /subscriptions/${_master_sub}/resourceGroups/${_container_rg}/providers/Microsoft.ContainerRegistry/registries/${_acr_name} \
    --description "Allow ACR Pull access to AKS Managed Identity"

  az aks update -n "${DP_CLUSTER_NAME}" -g "${DP_RESOURCE_GROUP}" \
    --attach-acr /subscriptions/${_master_sub}/resourceGroups/${_container_rg}/providers/Microsoft.ContainerRegistry/registries/${_acr_name}
fi

# get oidc issuer
export AKS_OIDC_ISSUER="$(az aks show -n ${DP_CLUSTER_NAME} -g "${DP_RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" -otsv)"

echo "create federated awi for ${USER_ASSIGNED_IDENTITY_NAME} in cert-manager/cert-manager"
az identity federated-credential create --name "cert-manager-cert-manager-federated" \
  --resource-group "${DP_RESOURCE_GROUP}" \
  --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject system:serviceaccount:cert-manager:cert-manager \
  --audience api://AzureADTokenExchange

# external dns configuration
AZURE_EXTERNAL_DNS_JSON_FILE=azure.json

cat <<-EOF > ${AZURE_EXTERNAL_DNS_JSON_FILE}
{
  "tenantId": "${TENANT_ID}",
  "subscriptionId": "${SUBSCRIPTION_ID}",
  "resourceGroup": "${DNS_RESOURCE_GROUP}",
  "useManagedIdentityExtension": true, 
  "userAssignedIdentityID": "${USER_ASSIGNED_IDENTITY_CLIENT_ID}"
}
EOF

##### FIX THIS #####
kubectl create ns external-dns-system
kubectl delete secret --namespace external-dns-system azure-config-file
kubectl create secret generic azure-config-file --namespace external-dns-system --from-file ./${AZURE_EXTERNAL_DNS_JSON_FILE}
##### FIX THIS #####

echo "create federated awi for ${USER_ASSIGNED_IDENTITY_NAME} in external-dns-system/external-dns"
az identity federated-credential create --name "external-dns-system-external-dns-federated" \
  --resource-group "${DP_RESOURCE_GROUP}" \
  --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject system:serviceaccount:external-dns-system:external-dns \
  --audience api://AzureADTokenExchange

rm -rf ./${AZURE_EXTERNAL_DNS_JSON_FILE}