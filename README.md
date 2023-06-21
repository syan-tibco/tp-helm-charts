# tp-helm-charts

This is temporary repo for helm charts for TIBCO Platform (TP) data plane components.

All the charts are supposed to submit under (charts)[charts] folder. 

The charts are supposed to be used by helm repo hosted on github pages. There is a github action to update the helm repo index.yaml file and automatically release new charts if the chart version is updated.

## How to use

```bash
helm repo add tibco-platform https://syan-tibco.github.io/tp-helm-charts/
helm repo update tibco-platform

helm upgrade --install --create-namespace -n <namespace> <release name> tibco-platform/<your chart> -f <your values file>
```

## Config helm charts

`dp-config-ask` is used to create
* ask ingress
* ask certificate

`dp-config-aws` is used to create
* external ingress for DP cluster
* internal ingress for DP cluster
* usage: helm install -n citrix-system citrix .
* usage: helm install -n traefik-system traefik .

`dp-config-es` is used to create
* kibana 
* Elastic

## Agent helm charts

`dp-core-infrastructure` is used to deploy following to DP cluster
* tibtunnel
* provisioner-agent

`tp-provisioner-agent` is used for testing DP without CP
