# Helm Chart
The dp-core-infrastructure helm chart consist of following subcharts.
 - tp-tibtunnel
 - tp-provisioner-agent
 - haproxy-ingress

# Sample values
global:
  tibco:
    dataPlaneId: "abcd" # Mandatory
    subscriptionId: "abcd" # Mandatory
    serviceAccount: ""                                # customer provided service account

## Installing the Chart

```console
$ helm repo add tibco-platform https://syan-tibco.github.io/tp-helm-charts/
$ helm install dp-core-infrastructure tibco-platform/dp-core-infrastructure