# tp-helm-charts

This is a temporary repo for helm charts for TIBCO Platform (TP) data plane components.

All the charts are supposed to submit under [charts](charts) folder. 

The charts are supposed to be used by helm repo hosted on github pages. There is a github action to update the helm repo index.yaml file and automatically release new charts if the chart version is updated.

## How to use

```bash
helm repo add tibco-platform https://syan-tibco.github.io/tp-helm-charts/
helm repo update tibco-platform

helm upgrade --install --create-namespace -n <namespace> <release name> tibco-platform/<your chart> -f <your values file>
```

## Chart release process
* Update the chart version in Chart.yaml
* Update release annotations in Chart.yaml. eg. [link](https://github.com/kubernetes-sigs/external-dns/blob/master/charts/external-dns/Chart.yaml). detailed spec [link](https://artifacthub.io/docs/topics/annotations/helm/)

## Agent helm charts

[dp-core-infrastructure](charts/dp-core-infrastructure) is used to create
* tp-tibtunnel
* tp-provisioner-agent
* tp-cp-proxy

[tp-provisioner-agent](charts/tp-provisioner-agent) is used for testing DP without CP

## helm charts

[dp-config-aks](charts/dp-config-aks) is used to create
* aks ingress
* aks certificate

[dp-config-aws](charts/dp-config-aws) is used to create
* external ingress for DP cluster
* internal ingress for DP cluster
* usage: helm install -n citrix-system citrix .
* usage: helm install -n traefik-system traefik .

[dp-config-es](charts/dp-config-es) is used to create
* kibana 
* Elastic

[dp-otel-collectors](charts/dp-otel-collectors) is used to create
* OTel collectors
