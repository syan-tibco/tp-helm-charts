Use-case 1:

Customer has created new namespaces and wants to create new service-account, cluster-role, cluster-role-binding and role-binding

## set of global values to obtain the details of service account and dataplane id
global:
  tibco:
    serviceAccount: "service-account" # customer provided service account
    dataPlaneId: "abcd"

# details of the dataplane namespace
dataplaneNamespaceName: ""

# details of namespaces
namespaces:
  dp-namespace:
    createBinding: true

Use-case 2:

Customer has created new namespaces but the service-account, cluster-roles, cluster-role-binidng are already present in bootstrapping namespace, and new role-binding has to be created for the new namespace.

## this creates role-binding in the specific namespace
global:
  tibco:
    serviceAccount: "service-account" # customer provided service account
    dataPlaneId: "abcd" # data plane id

# details of the dataplane namespace
dataplaneNamespaceName: "dp-namespace"

# details of namespaces
namespaces:
  app-namespace:
    createBinding: true