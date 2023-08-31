# BWCE Provisioner Helm Chart

This repository hosts the official **[BWCE Provisioner](https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/bwprovisioner) Helm Charts** for deploying **BW Provisioner** products to [Kubernetes](https://kubernetes.io/)

## Install Helm (only V3 is supported)

Get the latest [Helm release](https://github.com/helm/helm#install).

## Install Charts

### Add BWCE Provisioner Helm repository

Before installing BWCE Provisioner helm charts, you need to add the [BWCE Provisioner helm repository](https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/bwprovisioner) to your helm client.

```bash
helm repo add bwceprovisioner https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/bwprovisioner
helm repo update
```
### Install locally with override values

```bash
helm upgrade --install bwprovisioner [--namespace <namespace>] --values <new file name>.yaml
Or
helm upgrade --install bwprovisioner [--namespace <namespace>] -f <new file name>.yaml
```

**Note:** For instructions on how to install a chart follow instructions in its _README.md_.

## Contributing to BWCE Provisioner Charts

Fork the `repo`, make changes and then please run `helm lint` to lint charts locally, and at least install the chart to see it is working. :)

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR) on to the `master` branch.

We will take this PR changes internally, review and test.

Upon successful review , someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.

We will add PR changes in upcoming releases and credit the contributor with PR link in changelog (and also closing the PR raised by contributor).


