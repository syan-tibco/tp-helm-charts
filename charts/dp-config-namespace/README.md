Use-case 1:

Customer has created new namespaces and wants to create new service-account, cluster-role, cluster-role-binding and role-binding

## this creates cluster roles which are not namespaced
clusterRole:
  create: true
  createBinding: true

## this creates service account, role-binding
namespaces:
  - name: "namespacea"
    createBinding: true
  - name: "namespaceb"
    createBinding: true

## this creates service account and uses it for role-binding
serviceAccount:
  create: true
  name: "sa"
  namespaceName: "namespacea"


Use-case 2:

Customer has created new namespaces but the service-account, cluster-roles, cluster-role-binidng are already present.And new role-binding has to be created for the new namespace.

## this should be set to false as cluster roles are already created 
clusterRole:
  create: true

## this creates role-binding in the specific namespace
namespaces:
  - name: "namespacea"
    createBinding: true
  - name: "namespaceb"
    createBinding: true
  - name: "namespacec"
    createBinding: true

## this uses service account in the role-binding
serviceAccount:
  create: true
  name: "sa"
  namespaceName: "namespacea"