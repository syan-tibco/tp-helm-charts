Table of Contents
=================
<!-- TOC -->
* [Table of Contents](#table-of-contents)
* [TIBCO Data Plane Cluster Workshop](#tibco-data-plane-cluster-workshop)
  * [Introduction](#introduction)
  * [Command Line Tools needed](#command-line-tools-needed)
  * [Azure Login](#azure-login)
  * [Create AKS cluster](#create-aks-cluster)
  * [Generate kubeconfig to connect to AKS cluster](#generate-kubeconfig-to-connect-to-aks-cluster)
  * [Configure cluster](#configure-cluster)
  * [Install common third party tools](#install-common-third-party-tools)
  * [Install Ingress Controller, Storage class](#install-ingress-controller-storage-class)
    * [Setup DNS](#setup-dns)
    * [Configure Azure Files, Ingress](#configure-azure-files-ingress)
    * [Storage class](#storage-class)
  * [Install Observability tools](#install-observability-tools)
    * [Install Elastic stack](#install-elastic-stack)
    * [Install Prometheus stack](#install-prometheus-stack)
    * [Install Opentelemetry Collector for metrics](#install-opentelemetry-collector-for-metrics)
  * [Information needed to be set on TIBCO Control Plane](#information-needed-to-be-set-on-tibco-control-plane)
  * [Clean up](#clean-up)
<!-- TOC -->

# TIBCO Data Plane Cluster Workshop

The goal of this workshop is to provide a hands-on experience to deploy a TIBCO Data Plane cluster in Azure. This is the prerequisite for the TIBCO Data Plane.

## Introduction

In order to deploy TIBCO Data Plane, you need to have a Kubernetes cluster and install the necessary tools. This workshop will guide you to create a Kubernetes cluster in Azure and install the necessary tools.

## Command Line Tools needed

We are running the steps in a MacBook Pro. The following tools are installed using [brew](https://brew.sh/): 
* envsubst
* yq (v4.35.2)
* jq (1.7)
* bash (5.2.15)
* az (az-cli/2.53.1)
* kubectl (v1.28.3)
* helm (v3.13.1)

## Azure Login
We have used the contributor role which has access to create resources in a given subscription. 

## Create AKS cluster
```
Execute the script 
```bash
./aks-cluster-create.sh
```
It will take around 15 minutes to create an empty AKS cluster. 

## Configure cluster
Execute the script 
```bash
./configure-cluster.sh
```
It will take around 10 minutes to do the following configuration: 

## Adding additional IPs to access cluster
By default, your VPN IPs will be added as part of the configure-cluster.sh command above.
To add more IPs to be allowed to access the cluster, use the following code snippet
> [!Note]
> Additional IPs are required only when you are not using VPN.
> The rules can take up to two minutes to propagate. Please allow up to that time when testing the connection.
```bash
export DP_RESOURCE_GROUP=dp-resource-group
export DP_CLUSTER_NAME=dp-cluster
export MY_PUBLIC_IP="" ## add one or more comma separated non-duplicate public IPs with /32 CIDR without any spaces
CURRENT_IP=$(az aks show --resource-group ${DP_RESOURCE_GROUP} --name ${DP_CLUSTER_NAME} --query apiServerAccessProfile.authorizedIpRanges -o tsv | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}')
ARRAY_CURRENT_IP=(`echo ${CURRENT_IP}`)
ADDITIONAL_IP=$(echo ${ARRAY_CURRENT_IP} | sed 's/$/,/' | xargs | sed 's/[[:blank:]]//g')${MY_PUBLIC_IP}
az aks update --resource-group ${DP_RESOURCE_GROUP} --name ${DP_CLUSTER_NAME} --api-server-authorized-ip-ranges "${ADDITIONAL_IP}"
```

## Generate kubeconfig to connect to AKS cluster
We can use the following command to generate kubeconfig file.
```bash
export AZURE_REGION=eastus
export DP_RESOURCE_GROUP=dp-resource-group
export DP_CLUSTER_NAME=dp-cluster
az aks install-cli
az aks get-credentials --resource-group ${DP_RESOURCE_GROUP} --name ${DP_CLUSTER_NAME} --overwrite-existing
```

And check the connection to AKS cluster.
```bash
kubectl get nodes
```

## Install common third party tools

Before we deploy ingress or observability tools on an empty AKS cluster; we need to install some basic tools. 
* [cert-manager](https://cert-manager.io/docs/installation/helm/)
* [external-dns](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)

<details>

<summary>We can use the following commands to install these tools......</summary>

```bash
# install cert-manager
helm upgrade --install --wait --timeout 1h --create-namespace --reuse-values \
  -n cert-manager cert-manager cert-manager \
  --labels layer=0 \
  --repo "https://charts.jetstack.io" --version "v1.12.3" -f - <<EOF
installCRDs: true
podLabels:
  azure.workload.identity/use: "true"
serviceAccount:
  labels:
    azure.workload.identity/use: "true"
EOF

```bash
# install external-dns
export DP_RESOURCE_GROUP=dp-resource-group
export DP_CLUSTER_NAME=dp-cluster
export DP_DNS_RESOURCE_GROUP=cic-dns
export AZURE_REGION=eastus
export AZURE_EXTERNAL_DNS_SA_NAMESPACE="external-dns-system"
export MAIN_INGRESS_CLASS_NAME="azure-application-gateway"
export DP_DOMAIN="dp1.azure.dataplanes.pro"

helm upgrade --install --wait --timeout 1h --reuse-values \
  -n ${AZURE_EXTERNAL_DNS_SA_NAMESPACE} external-dns external-dns \
  --labels layer=0 \
  --repo "https://kubernetes-sigs.github.io/external-dns" --version "1.13.0" -f - <<EOF
provider: azure
sources:
  - service
  - ingress
domainFilters:
  - ${DP_DOMAIN}
extraVolumes: # for azure.json
- name: azure-config-file
  secret:
    secretName: azure-config-file
extraVolumeMounts:
- name: azure-config-file
  mountPath: /etc/kubernetes
  readOnly: true
extraArgs:
- --ingress-class=${MAIN_INGRESS_CLASS_NAME}
EOF
```
</details>

<details>

<summary>Sample output of third party helm charts that we have installed in the EKS cluster...</summary>

```bash
$ helm ls -A -a
NAME                         	NAMESPACE          	REVISION	UPDATED                                	STATUS  	CHART                                                                APP VERSION
aks-managed-workload-identity	kube-system        	956     	2023-11-03 11:51:09.441169483 +0000 UTC	deployed	workload-identity-addon-0.1.0-575c84365b912ce669b63fe9cb46727096e72c3           
cert-manager                 	cert-manager       	1       	2023-11-03 17:11:50.00057 +0530 IST    	deployed	cert-manager-v1.12.3                                                 v1.12.3    
external-dns                 	external-dns-system	1       	2023-11-03 17:17:00.469065 +0530 IST   	deployed	external-dns-1.13.0                                                  0.13.5        
```
</details>

## Install Ingress Controller, Storage class

Use the following command to get the ingress class name.
```bash
kubectl get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       19m
```

In this section, we will install ingress controller and storage class. We have made a helm chart called `dp-config-aks` that encapsulates the installation of ingress controller and storage class. 
It will create the following resources:
* a main ingress object which will be able to create Azure Application Gateway and act as a main ingress for DP cluster
* annotation for external-dns to create DNS record for the main ingress
* a storage class for Azure Block Storage
* a storage class for Azure Files

### Setup DNS
For this workshop we will use `dp1.azure.dataplanes.pro` as the domain name. We will use `*.dp1.azure.dataplanes.pro` as the wildcard domain name for all the DP capabilities.
We are using the following services in this workshop:
* [DNS Zones](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records): to manage DNS. We register `azure.dataplanes.pro` in Azure DNS Zones.
* [Let's Encrypt](https://cert-manager.io/docs/configuration/acme/dns01/azuredns/): to manage SSL certificate. We will create a wildcard certificate for `*.dp1.azure.dataplanes.pro`.
* azure-application-gateway: to create Application Gateway. It will automatically create listeners and add SSL certificate to application gateway.
* external-dns: to create DNS record in dns zone for the record set. It will automatically create DNS record for ingress objects.

For this workshop work; you will need to 
* register a domain name in Route 53. You can follow this [link](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html) to register a domain name in Route 53.
* create a wildcard certificate in ACM. You can follow this [link](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) to create a wildcard certificate in ACM.

### Configure Azure Files, Ingress


```bash
export TIBCO_DP_HELM_CHART_REPO=https://syan-tibco.github.io/tp-helm-charts
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export DP_RESOURCE_GROUP=dp-resource-group
export DP_DNS_RESOURCE_GROUP=cic-dns
export DP_CLUSTER_NAME=dp-cluster
export CLIENT_ID=$(az aks show --resource-group "${DP_RESOURCE_GROUP}" --name "${DP_CLUSTER_NAME}" --query "identityProfile.kubeletidentity.clientId" --output tsv)
export DP_TOP_LEVEL_DOMAIN="azure.dataplanes.pro"
export DP_SANDBOX_SUBDOMAIN="dp1"
export DP_DOMAIN="dp1.azure.dataplanes.pro"
export MAIN_INGRESS_CLASS_NAME="azure-application-gateway"
export STORAGE_ACCOUNT_NAME="templatestorageaccount3"
export STORAGE_ACCOUNT_RESOURCE_GROUP="azrtroposdev-CloudInfraEngineering-template"
export DP_DISK_ENABLED=false
export DP_FILE_ENABLED=true
## following section is required to send traces using nginx
## uncomment the below commented section to run/re-run the command, once DP_NAMESPACE is available
export DP_NAMESPACE="ns"

helm upgrade --install --wait --timeout 1h --create-namespace \
  -n ingress-system dp-config-aks dp-config-aks \
  --labels layer=1 \
  --repo "${TIBCO_DP_HELM_CHART_REPO}" --version "1.0.11" -f - <<EOF
global:
  dnsSandboxSubdomain: "${DP_SANDBOX_SUBDOMAIN}"
  dnsGlobalTopDomain: "${DP_TOP_LEVEL_DOMAIN}"
  azureSubscriptionDnsResourceGroup: "${DP_DNS_RESOURCE_GROUP}"
  azureSubscriptionId: "${AZURE_SUBSCRIPTION_ID}"
  azureAwiAsoDnsClientId: "${CLIENT_ID}"
dns:
  domain: "${DP_DOMAIN}"
httpIngress:
  ingressClassName: ${MAIN_INGRESS_CLASS_NAME}
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "*.${DP_DOMAIN}"
storageClass:
  azuredisk:
    enabled: ${DP_DISK_ENABLED}
  azurefile:
    enabled: ${DP_FILE_ENABLED}
    parameters:
      storageAccount: ${STORAGE_ACCOUNT_NAME}
      resourceGroup: ${STORAGE_ACCOUNT_RESOURCE_GROUP}
ingress-nginx:
  controller:
    config:
      use-forwarded-headers: "true"
      enable-opentelemetry: "true"
      log-level: debug
      opentelemetry-config: /etc/nginx/opentelemetry.toml
      opentelemetry-operation-name: HTTP $request_method $service_name $uri
      opentelemetry-trust-incoming-span: "true"
      otel-max-export-batch-size: "512"
      otel-max-queuesize: "2048"
      otel-sampler: AlwaysOn
      otel-sampler-parent-based: "false"
      otel-sampler-ratio: "1.0"
      otel-schedule-delay-millis: "5000"
      otel-service-name: nginx-proxy
      otlp-collector-host: otel-userapp.${DP_NAMESPACE}.svc
      otlp-collector-port: "4317"
    opentelemetry:
      enabled: true
EOF
```

Use the following command to get the ingress class name.
```bash
$ kubectl get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       24m
nginx                       k8s.io/ingress-nginx        <none>       2m18s
```

The `nginx` ingress class is the main ingress that DP will use. The `azure-application-gateway` ingress class is used by Azure Application Gateway.

> [!IMPORTANT]
> You will need to provide this ingress class name i.e. nginx to TIBCO Control Plane when you deploy capability.

### Storage class

Use the following command to get the storage class name.

```bash
$ kubectl get storageclass
NAME                    PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azure-files-sc          file.csi.azure.com   Delete          WaitForFirstConsumer   true                   2m35s
azurefile               file.csi.azure.com   Delete          Immediate              true                   24m
azurefile-csi           file.csi.azure.com   Delete          Immediate              true                   24m
azurefile-csi-premium   file.csi.azure.com   Delete          Immediate              true                   24m
azurefile-premium       file.csi.azure.com   Delete          Immediate              true                   24m
default (default)       disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   24m
managed                 disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   24m
managed-csi             disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   24m
managed-csi-premium     disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   24m
managed-premium         disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   24m
```

We have some scripts in the recipe to create and setup EFS. The `dp-config-aws` helm chart will create all these storage classes.
* `managed-csi` is the storage class for Azure Block Storage. This is used for
  * storage class for data when provision EMS capability
* `azure-files-sc` is the storage class for Azure Files. This is used for
  * artifactmanager when we provision BWCE capability
  * storage class for log when we provision EMS capability
* `default` is the default storage class for AKS. Azure create it by default and don't recommend to use it.

> [!IMPORTANT]
> You will need to provide this storage class name to TIBCO Control Plane when you deploy capability.

## Install Observability tools

### Install Elastic stack

<details>

<summary>Use the following command to install Elastic stack...</summary>

```bash
# install eck-operator
helm upgrade --install --wait --timeout 1h --labels layer=1 --create-namespace -n elastic-system eck-operator eck-operator --repo "https://helm.elastic.co" --version "2.9.0"

# install dp-config-es
export TIBCO_DP_HELM_CHART_REPO=https://syan-tibco.github.io/tp-helm-charts
export DP_DOMAIN=dp1.azure.dataplanes.pro
export DP_ES_RELEASE_NAME=dp-config-es
export DP_INGRESS_CLASS=nginx
export DP_STORAGE_CLASS=managed-csi

helm upgrade --install --wait --timeout 1h --create-namespace --reuse-values \
  -n elastic-system dp-config-es ${DP_ES_RELEASE_NAME} \
  --labels layer=2 \
  --repo "${TIBCO_DP_HELM_CHART_REPO}" --version "1.0.15" -f - <<EOF
domain: ${DP_DOMAIN}
es:
  version: "8.9.1"
  ingress:
    ingressClassName: ${DP_INGRESS_CLASS}
    service: ${DP_ES_RELEASE_NAME}-es-http
  storage:
    name: ${DP_STORAGE_CLASS}
kibana:
  version: "8.9.1"
  ingress:
    ingressClassName: ${DP_INGRESS_CLASS}
    service: ${DP_ES_RELEASE_NAME}-kb-http
apm:
  enabled: true
  version: "8.9.1"
  ingress:
    ingressClassName: ${DP_INGRESS_CLASS}
    service: ${DP_ES_RELEASE_NAME}-apm-http
EOF
```
</details>

Use this command to get the host URL for Kibana
```bash
kubectl get ingress -n elastic-system dp-config-es-kibana -oyaml | yq eval '.spec.rules[0].host'
```

The username is normally `elastic`. We can use the following command to get the password.
```bash
kubectl get secret dp-config-es-es-elastic-user -n elastic-system -o jsonpath="{.data.elastic}" | base64 --decode; echo
```

### Install Prometheus stack

<details>

<summary>Use the following command to install Prometheus stack...</summary>

```bash
# install prometheus stack
export DP_DOMAIN=dp1.azure.dataplanes.pro
export DP_INGRESS_CLASS=nginx

helm upgrade --install --wait --timeout 1h --create-namespace --reuse-values \
  -n prometheus-system kube-prometheus-stack kube-prometheus-stack \
  --labels layer=2 \
  --repo "https://prometheus-community.github.io/helm-charts" --version "48.3.4" -f <(envsubst '${DP_DOMAIN}, ${DP_INGRESS_CLASS}' <<'EOF'
grafana:
  plugins:
    - grafana-piechart-panel
  ingress:
    enabled: true
    ingressClassName: ${DP_INGRESS_CLASS}
    hosts:
    - grafana.${DP_DOMAIN}
prometheus:
  prometheusSpec:
    enableRemoteWriteReceiver: true
    remoteWriteDashboards: true
    additionalScrapeConfigs:
    - job_name: otel-collector
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - action: keep
        regex: "true"
        source_labels:
        - __meta_kubernetes_pod_label_prometheus_io_scrape
      - action: keep
        regex: "infra"
        source_labels:
        - __meta_kubernetes_pod_label_platform_tibco_com_workload_type
      - action: keepequal
        source_labels: [__meta_kubernetes_pod_container_port_number]
        target_label: __meta_kubernetes_pod_label_prometheus_io_port
      - action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        source_labels:
        - __address__
        - __meta_kubernetes_pod_label_prometheus_io_port
        target_label: __address__
      - source_labels: [__meta_kubernetes_pod_label_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
        replacement: /$1
  ingress:
    enabled: true
    ingressClassName: ${DP_INGRESS_CLASS}
    hosts:
    - prometheus-internal.${DP_DOMAIN}
EOF
)
```
</details>

Use this command to get the host URL for Kibana
```bash
kubectl get ingress -n prometheus-system kube-prometheus-stack-grafana -oyaml | yq eval '.spec.rules[0].host'
```

The username is `admin`. And Prometheus Operator use fixed password: `prom-operator`.

### Install Opentelemetry Collector for metrics

<details>

<summary>Use the following command to install Opentelemetry Collector for metrics...</summary>

```bash
# Copy the below content to a YAML file values.yaml
# Make sure the indetations are right.
mode: "daemonset"
fullnameOverride: otel-kubelet-stats
podLabels:
  platform.tibco.com/workload-type: "infra"
  networking.platform.tibco.com/kubernetes-api: enable
  egress.networking.platform.tibco.com/internet-all: enable
  prometheus.io/scrape: "true"
  prometheus.io/path: "metrics"
  prometheus.io/port: "4319"
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 15
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
serviceAccount:
  create: true
clusterRole:
  create: true
  rules:
  - apiGroups: [""]
    resources: ["pods", "namespaces"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["nodes/stats", "nodes/proxy"]
    verbs: ["get"]
extraEnvs:
  - name: KUBE_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
ports:
  metrics:
    enabled: true
    containerPort: 8888
    servicePort: 8888
    hostPort: 8888
    protocol: TCP
  prometheus:
    enabled: true
    containerPort: 4319
    servicePort: 4319
    hostPort: 4319
    protocol: TCP
config:
  receivers:
    kubeletstats/user-app:
      collection_interval: 20s
      auth_type: "serviceAccount"
      endpoint: "https://${env:KUBE_NODE_NAME}:10250"
      insecure_skip_verify: true
      metric_groups:
        - pod
        - container
      extra_metadata_labels:
        - container.id
      metrics:
        k8s.container.memory_limit_utilization:
          enabled: true
        k8s.container.cpu_limit_utilization:
          enabled: true
        k8s.pod.cpu_limit_utilization:
          enabled: true
        k8s.pod.memory_limit_utilization:
          enabled: true
        k8s.pod.filesystem.available:
          enabled: false
        k8s.pod.filesystem.capacity:
          enabled: false
        k8s.pod.filesystem.usage:
          enabled: false
        k8s.pod.memory.major_page_faults:
          enabled: false
        k8s.pod.memory.page_faults:
          enabled: false
        k8s.pod.memory.rss:
          enabled: false
        k8s.pod.memory.working_set:
          enabled: false
  processors:
    memory_limiter:
      check_interval: 5s
      limit_percentage: 80
      spike_limit_percentage: 25
    batch: {}
    k8sattributes/kubeletstats:
      auth_type: "serviceAccount"
      passthrough: false
      extract:
        metadata:
          - k8s.pod.name
          - k8s.pod.uid
          - k8s.namespace.name
        annotations:
          - tag_name: connectors
            key: platform.tibco.com/connectors
            from: pod
        labels:
          - tag_name: app_id
            key: platform.tibco.com/app-id
            from: pod
          - tag_name: app_type
            key: platform.tibco.com/app-type
            from: pod
          - tag_name: dataplane_id
            key: platform.tibco.com/dataplane-id
            from: pod
          - tag_name: workload_type
            key: platform.tibco.com/workload-type
            from: pod
          - tag_name: app_name
            key: platform.tibco.com/app-name
            from: pod
          - tag_name: app_version
            key: platform.tibco.com/app-version
            from: pod
          - tag_name: app_tags
            key: platform.tibco.com/tags
            from: pod
      pod_association:
        - sources:
            - from: resource_attribute
              name: k8s.pod.uid
    filter/user-app:
      metrics:
        include:
          match_type: strict
          resource_attributes:
            - key: workload_type
              value: user-app
    transform/metrics:
      metric_statements:
      - context: datapoint
        statements:
          - set(attributes["pod_name"], resource.attributes["k8s.pod.name"])
          - set(attributes["pod_namespace"], resource.attributes["k8s.namespace.name"])
          - set(attributes["app_id"], resource.attributes["app_id"])
          - set(attributes["app_type"], resource.attributes["app_type"])
          - set(attributes["dataplane_id"], resource.attributes["dataplane_id"])
          - set(attributes["workload_type"], resource.attributes["workload_type"])
          - set(attributes["app_tags"], resource.attributes["app_tags"])
          - set(attributes["app_name"], resource.attributes["app_name"])
          - set(attributes["app_version"], resource.attributes["app_version"])
          - set(attributes["connectors"], resource.attributes["connectors"])
    filter/include:
      metrics:
        include:
          match_type: regexp
          metric_names:
            - .*memory.*
            - .*cpu.*
  exporters:
    prometheus/user:
      endpoint: 0.0.0.0:4319
      enable_open_metrics: true
      resource_to_telemetry_conversion:
        enabled: true
  extensions:
    health_check: {}
    memory_ballast:
      size_in_percentage: 40
  service:
    telemetry:
      logs: {}
      metrics:
        address: :8888
    extensions:
      - health_check
      - memory_ballast
    pipelines:
      logs: null
      traces: null
      metrics:
        receivers:
          - kubeletstats/user-app
        processors:
          - k8sattributes/kubeletstats
          - filter/user-app
          - filter/include
          - transform/metrics
          - batch
        exporters:
          - prometheus/user
```

```bash
# Run the helm upgrade command passing the above values.yaml file

helm upgrade --install --wait --timeout 1h --create-namespace --reuse-values \
  -n prometheus-system otel-collector-daemon opentelemetry-collector \
  --labels layer=2 \
  --repo "https://open-telemetry.github.io/opentelemetry-helm-charts" --version "0.72.0" -f values.yaml
```
</details>

## Information needed to be set on TIBCO Control Plane

You can get base FQDN by running the following command:
```bash
kubectl get ingress -n ingress-system nginx |  awk 'NR==2 { print $3 }'
```

| Name                 | Sample value                                                                     | Notes                                                                     |
|:---------------------|:---------------------------------------------------------------------------------|:--------------------------------------------------------------------------|
| VPC_CIDR             | 10.224.0.0/12                                                                    | you can find this from eks recipe                                         |
| ingress class name   | nginx                                                                            | this is used for BWCE                                                     |
| Azure Files storage class    | azure-files-sc                                                                           | this is used for BWCE EFS storage                                         |
| Azure Disks storage class    | managed-csi                                                                          | this is used for EMS messaging                                            |
| BW FQDN              | bwce.\<base FQDN\>                                                               | this is the main domain plus any name you want to use for this capability |
| User app log index   | user-app-1                                                                       | this comes from dp-config-es index template                               |
| service ES index     | service-1                                                                        | this comes from dp-config-es index template                               |
| ES internal endpoint | https://dp-config-es-es-http.elastic-system.svc.cluster.local:9200               | this comes from ES service                                                |
| ES public endpoint   | https://elastic.\<base FQDN\>                                                    | this comes from ES ingress                                                |
| ES password          | xxx                                                                              | see above ES password                                                     |
| tracing server host  | https://dp-config-es-es-http.elastic-system.svc.cluster.local:9200               | same as elastic internal endpoint                                         |
| Prometheus endpoint  | http://kube-prometheus-stack-prometheus.prometheus-system.svc.cluster.local:9090 | this comes from Prometheus service                                        |
| Grafana endpoint  | https://grafana.\<base FQDN\> | this comes from Grafana service                                        |

## Clean up

We provide a helper [clean-up](clean-up.sh) to delete the EKS cluster.
```bash
export DP_CLUSTER_NAME=dp-cluster
./clean-up.sh ${DP_CLUSTER_NAME}
```
