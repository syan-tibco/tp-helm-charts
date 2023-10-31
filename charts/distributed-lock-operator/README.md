## NOTE :
If user provided service account is empty then default service account is created as part of distributed lock operator helm chart.

# Sample values
global:
  tibco:
    dataPlaneId: "abcd" # Mandatory
    subscriptionId: "abcd" # Mandatory


## Installing the Chart

```console
$ helm repo add tibco-platform https://syan-tibco.github.io/tp-helm-charts/
$ helm install distributed-lock-operator tibco-platform/distributed-lock-operator