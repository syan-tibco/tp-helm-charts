# Sample values
global:
  tibco:
    dataPlaneId: "abcd" # Mandatory
    subscriptionId: "abcd" # Mandatory

## Installing the Chart

```console
$ helm repo add tibco-platform https://syan-tibco.github.io/tp-helm-charts/
$ helm install tp-dp-secret-controller tibco-platform/tp-dp-secret-controller