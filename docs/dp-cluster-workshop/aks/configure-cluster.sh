#!/bin/bash
set +x

export USER_ASSIGNED_IDENTITY_CLIENT_ID=$(az aks show --resource-group "${DP_RESOURCE_GROUP}" --name "${DP_CLUSTER_NAME}" --query "identityProfile.kubeletidentity.clientId" --output tsv)
export USER_ASSIGNED_IDENTITY_PRINCIPAL_ID=$(az aks show --resource-group "${DP_RESOURCE_GROUP}" --name "${DP_CLUSTER_NAME}" --query "identityProfile.kubeletidentity.objectId" --output tsv)
export USER_ASSIGNED_IDENTITY_OBJECT_ID="${USER_ASSIGNED_IDENTITY_PRINCIPAL_ID}"

# add contributor privileged role
# required to create resources
az role assignment create --assignee-object-id "${USER_ASSIGNED_IDENTITY_OBJECT_ID}" \
  --assignee-principal-type "ServicePrincipal" --role "Contributor" \
  --scope /subscriptions/${SUBSCRIPTION_ID} \
  --description "Allow Contributor access to AKS Managed Identity"

# add dns zone contributor permission
# required to create new record sets in dns zone
az role assignment create \
  --role "DNS Zone Contributor" \
  --assignee-object-id "${USER_ASSIGNED_IDENTITY_OBJECT_ID}" \
  --assignee-principal-type "ServicePrincipal" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${DP_DNS_RESOURCE_GROUP}"

# get oidc issuer
export AKS_OIDC_ISSUER="$(az aks show -n ${DP_CLUSTER_NAME} -g "${DP_RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" -otsv)"

# workload identity federation for cert manager
echo "create federated workload identity federation for ${USER_ASSIGNED_IDENTITY_NAME} in cert-manager/cert-manager"
az identity federated-credential create --name "cert-manager-cert-manager-federated" \
  --resource-group "${DP_RESOURCE_GROUP}" \
  --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject system:serviceaccount:cert-manager:cert-manager \
  --audience api://AzureADTokenExchange

# workload identity federation for external dns system
echo "create federated workload identity federation for ${USER_ASSIGNED_IDENTITY_NAME} in external-dns-system/external-dns"
az identity federated-credential create --name "external-dns-system-external-dns-federated" \
  --resource-group "${DP_RESOURCE_GROUP}" \
  --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject system:serviceaccount:external-dns-system:external-dns \
  --audience api://AzureADTokenExchange

# external dns configuration
AZURE_EXTERNAL_DNS_JSON_FILE=azure.json

cat <<-EOF > ${AZURE_EXTERNAL_DNS_JSON_FILE}
{
  "tenantId": "${TENANT_ID}",
  "subscriptionId": "${SUBSCRIPTION_ID}",
  "resourceGroup": "${DP_DNS_RESOURCE_GROUP}",
  "useManagedIdentityExtension": true, 
  "userAssignedIdentityID": "${USER_ASSIGNED_IDENTITY_CLIENT_ID}"
}
EOF

# connect to cluster
az aks get-credentials --name "${DP_CLUSTER_NAME}" --resource-group "${DP_RESOURCE_GROUP}" --file "${KUBECONFIG}" --overwrite-existing

# create namespace and secrets for external-dns-system
kubectl create ns external-dns-system
kubectl delete secret --namespace external-dns-system azure-config-file
kubectl create secret generic azure-config-file --namespace external-dns-system --from-file ./${AZURE_EXTERNAL_DNS_JSON_FILE}

rm -rf ./${AZURE_EXTERNAL_DNS_JSON_FILE}