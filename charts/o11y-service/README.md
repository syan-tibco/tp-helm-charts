# O11Y Service Helm Chart

This repository hosts the official **[O11Y Service](https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/o11y-service) Helm Charts** for deploying **O11Y Service** products to [Kubernetes](https://kubernetes.io/)

## Install Helm (only V3 is supported)

Get the latest [Helm release](https://github.com/helm/helm#install).

## Install Charts

### Add O11Y Service Helm repository

Before installing O11Y Service helm charts, you need to add the [O11Y Service helm repository](https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/o11y-service) to your helm client.

```bash
helm repo add o11y-service https://github.com/sasahoo-tibco/tp-integration/tree/main/helm/charts/o11y-service
helm repo update
```
### Install locally with override values

```bash
helm upgrade --install o11y-service [--namespace <namespace>] --values <new file name>.yaml
Or
helm upgrade --install o11y-service [--namespace <namespace>] -f <new file name>.yaml
```

**Note:** For instructions on how to install a chart follow instructions in its _README.md_.

## Contributing to O11Y Service Charts

Fork the `repo`, make changes and then please run `helm lint` to lint charts locally, and at least install the chart to see it is working. :)

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR) on to the `master` branch.

We will take this PR changes internally, review and test.

Upon successful review , someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.

We will add PR changes in upcoming releases and credit the contributor with PR link in changelog (and also closing the PR raised by contributor).


