# Nuxeo Platform CI

Infrastructure and Configuration as Code for the Platform team CI system.

## Setup

Install [Pulumi](https://www.pulumi.com/docs/get-started/install/).

Install [Node.js](https://nodejs.org/en/download/).

Install a package manager for Node.js, such as [npm](https://www.npmjs.com/get-npm) or [Yarn](https://yarnpkg.com/en/docs/install).

pnpm

Install [Google Cloud SDK](https://cloud.google.com/sdk/install).

Set Up Google Cloud Platform (GCP)

```shell
gcloud auth login
gcloud config set project <YOUR_GCP_PROJECT_HERE>
gcloud auth application-default login
```

Set Up Kube

https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

kubectl config view

kubectl config view --minify

kubectl config get-contexts

kubectl config use-context xxx
