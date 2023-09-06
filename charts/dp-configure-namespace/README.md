## Use-case 1:

Customer has created new namespace and applied the Tibco platform dataplane labels.
Customer now wants to create new service-account, cluster-role, cluster-role-binding and role-binding

#  Release Namespace and Primary Namespace
.Release.Namespace is same as .Values.global.tibco.primaryNamespaceName.
So, service-account is created in this namespace, which will be referred in the subsequent application namespace configuration.

# sample payload
global:
  tibco:
    dataplaneId: "abcd" # Mandatory
    primaryNamespaceName: "dp-namespace" # Mandatory
    serviceAccount: "sa" # Mandatory

createServiceAccount: true # Default true

createNetworkPolicy: true # Default true
additionalNetworkPolicy: {}

## Use-case 2:

Customer has created new application namespace and applied the Tibco platform dataplane labels.
The cluster-roles, cluster-role-binidng are present and service-account in primary namespace is to be used.
To enable application deployment Customer needs to create role-binding in the new namespace.

#  Release Namespace and Primary Namespace
.Release.Namespace is NOT same as .Values.global.tibco.primaryNamespaceName.
So, only role-binding is created in this namespace.
Service Account is used from the primaryNamespaceName.

# set of global values to obtain the details of service account, dataplane id and primary namespace
global:
  tibco:
    dataplaneId: "abcd" # Mandatory
    primaryNamespaceName: "dp-namespace" # Mandatory
    serviceAccount: "sa" # Mandatory

createNetworkPolicy: true # Default true
additionalNetworkPolicy: {}
