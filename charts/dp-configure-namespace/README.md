## Use-case 1:

Customer has created new namespaces and wants to create new service-account, cluster-role, cluster-role-binding and role-binding

# set of global values to obtain the details of service account, dataplane id and primary namespace
global:
  tibco:
    subscriptionId: "sub1"
    dataplaneId: "abcd"
    primaryNamespaceName: "dp-namespace"
    serviceAccount: "sa" 

createServiceAccount: true

createNetworkPolicy: true
additionalNetworkPolicy: {}

## Use-case 2:

Customer has created new namespaces but the service-account, cluster-roles, cluster-role-binidng are already present and new role-binding has to be created for the new namespace.

# set of global values to obtain the details of service account, dataplane id and primary namespace
global:
  tibco:
    subscriptionId: "sub1"
    dataplaneId: "abcd"
    primaryNamespaceName: "dp-namespace"
    serviceAccount: "sa" 

createNetworkPolicy: true
additionalNetworkPolicy: {}
