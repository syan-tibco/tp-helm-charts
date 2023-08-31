Use-case 1:

Customer has created new namespaces and wants to create new service-account, cluster-role, cluster-role-binding and role-binding

## set of global values to obtain the details of service account and dataplane id
global:
  tibco:
    serviceAccount: "service-account" # customer provided service account
    dataPlaneId: "abcd"

## this creates cluster roles which are not namespaced
clusterRole:
  create: true
  createBinding: true

## this creates service account, role-binding
## Note, there is a restriction for namespace name to NOT inclue '-'
namespaces:
  namespacea:
    createBinding: true
  namespaceb:
    createBinding: true

Use-case 2:

Customer has created new namespaces but the service-account, cluster-roles, cluster-role-binidng are already present, and new role-binding has to be created for the new namespace.

## this creates role-binding in the specific namespace
namespaces:
  namespacec:
    createBinding: true