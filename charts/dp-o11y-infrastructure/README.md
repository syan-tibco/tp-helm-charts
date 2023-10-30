# dp-o11y-infrastructure Helm Chart

This repository hosts the official **[dp-o11y-infrastructure](https://github.com/syan-tibco/tp-helm-charts/tree/main/charts/dp-o11y-infrastructure) Helm Charts** for deploying **dp-o11y-infrastructure** products to [Kubernetes](https://kubernetes.io/)

## Install Helm (only V3 is supported)

Get the latest [Helm release](https://github.com/helm/helm#install).

## Install Charts

### Add dp-o11y-infrastructure Helm repository

Before installing dp-o11y-infrastructure helm charts, you need to add the [dp-o11y-infrastructure helm repository](https://github.com/syan-tibco/tp-helm-charts/tree/main/charts/dp-o11y-infrastructure) to your helm client.

```bash
helm repo add dp-o11y-infrastructure https://github.com/syan-tibco/tp-helm-charts/tree/main/charts/dp-o11y-infrastructure
helm repo update
```
### Install locally with override values

```bash
helm upgrade --install dp-o11y-infrastructure [--namespace <namespace>] --values <new file name>.yaml
Or
helm upgrade --install dp-o11y-infrastructure [--namespace <namespace>] -f <new file name>.yaml
```

**Note:** For instructions on how to install a chart follow instructions in its _README.md_.

## Contributing to dp-o11y-infrastructure Charts

Fork the `repo`, make changes and then please run `helm lint` to lint charts locally, and at least install the chart to see it is working. :)

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR) on to the `master` branch.

We will take this PR changes internally, review and test.

Upon successful review , someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.

We will add PR changes in upcoming releases and credit the contributor with PR link in changelog (and also closing the PR raised by contributor).


