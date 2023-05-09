# tp-helm-charts


## Config helm charts

`dp-config-aws` is used to create
* external ingress for DP cluster
* internal ingress for DP cluster
* usage: helm install -n citrix-system citrix dp-config-aws --create-namespace
* usage: helm install -n traefik-system traefik dp-config-aws --create-namespace
* usage: helm install -n nginx-system nginx dp-config-aws --create-namespace

`dp-config-es` is used to create
* kibana 
* Elastic

## Agent helm charts

`dp-core-infrastructure` is used to deploy following to DP cluster
* tibtunnel
* provisioner-agent

`tp-provisioner-agent` is used for testing DP without CP
