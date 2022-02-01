# Nuxeo Platform CI

Configuration as code for the Nuxeo Platform CI in Kubernetes.

## Principles

Jenkins is installed with the [Jenkins Helm chart](https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins).

The Jenkins Helm chart is deployed with [Helmfile](https://github.com/roboll/helmfile) and configured with a set of custom values overriding the [default](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/values.yaml) ones, defined in the `./charts/jenkins/values*.yaml.gotmpl` files.

This configuration mostly includes:

- Jenkins image
- Java options
- Jenkins plugins
- [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin) (JCasC), among which:
  - Authorization
  - Credentials
  - Jenkins and plugin configuration
  - Kubernetes Cloud configuration, including pod templates
  - Jobs, using the [Jenkins Job DSL Plugin](https://github.com/jenkinsci/job-dsl-plugin)

When [synchronizing the Kubernetes cluster](#kubernetes-cluster-synchronization) with the resources from the [helmfile](./helmfile.yaml), depending on the changes:

- The Jenkins pod will **not** be restarted if the changes only impact Jenkins Configuration as Code, thanks to the `config-reload` container that takes care of hot reloading the configuration. This includes pod templates and jobs!
- The Jenkins pod **will** be restarted if the changes impact anything else than Jenkins Configuration as Code, typically the Jenkins image, plugins or Java options.

## Requirements

- [Helm 3](https://helm.sh/docs/intro/install/)
- [Helmfile](https://github.com/roboll/helmfile#installation)
- [Helm Diff plugin](https://github.com/databus23/helm-diff#install)
- [Kustomize](https://kubernetes-sigs.github.io/kustomize/installation/)

## Installation

### Kubernetes Cluster Initialization

#### Target Namespace

Define the target namespace variable:

```shell
NAMESPACE=target-namespace
```

Create the `$NAMESPACE` namespace:

```shell
kubectl create ns $NAMESPACE
```

#### Secrets

Import the required secrets from the `platform` namespace:

```shell
./secrets/import-secrets.sh ./secrets/secrets platform
```

Create the secret containing the credentials for the Jenkins Configuration as Code (JCasC):

```shell
(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: jenkins-casc
data:
  gitHubOAuthClientId: ********
  gitHubOAuthSecret: ********
  gitHubUser: ********
  gitHubToken: ********
  gitHubAppKey: ********
  jiraPassword: ********
  slackToken: ********
EOF
) | kubectl apply --namespace=$NAMESPACE -f -
```

Create the secret containing the AWS credentials:

```shell
(
cat << EOF
apiVersion: v1
kind: Secret
metadata:
  name: aws-credentials
  annotations:
    meta.helm.sh/release-name: aws-credentials
    meta.helm.sh/release-namespace: $NAMESPACE
  labels:
    "app.kubernetes.io/managed-by": Helm
    aws-rotate-key: "true"
stringData:
  access_key_id: ********
  secret_access_key: ********
EOF
) | kubectl apply --namespace=$NAMESPACE -f -
```

The AWS credentials are rotated with the [AWS IAM key rotate tool](https://github.com/nuxeo-cloud/aws-iam-credential-rotate). The cron job schedule is configurable with the `cronjob.schedule` value.

#### Misc

Create the `ClusterRoleBinding` required for the `ServiceAccount` used by Jenkins, typically to create namespaces:

```shell
(
cat << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $NAMESPACE:jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: $NAMESPACE
EOF
) | kubectl apply -f -
```

### Kubernetes Cluster Synchronization

The following environment variables need to be set:

- Credentials for [packages.nuxeo.com](https://packages.nuxeo.com/):
  - `PACKAGES_USERNAME`
  - `PACKAGES_PASSWORD`

- Credentials for [Nuxeo Connect](http://connect.nuxeo.com/):
  - `CONNECT_USERNAME`
  - `CONNECT_PASSWORD`

Synchronize the Kubernetes cluster with the resources from the [helmfile](./helmfile.yaml).

```shell
helmfile deps
helmfile sync
```

The `default` Helmfile environment targets the `platform-staging` namespace. To target the `platform` namespace, specify the `production` environment:

```shell
helmfile deps
helmfile --environment production sync
```

See the `environments` section in the [helmfile](./helmfile.yaml) to understand the diff between the environments.

Have fun using Jenkins at [https://jenkins.\$NAMESPACE.dev.nuxeo.com/](https://jenkins.$NAMESPACE.dev.nuxeo.com/).

## Jenkins X Platform

While waiting to be migrated to standard Helm charts, as for Jenkins, the other CI components are still managed with the [Jenkins X Helm Charts](https://github.com/jenkins-x/jenkins-x-platform) throught the `jx upgrade platform` deprecated command:

- Nexus
- ChartMuseum
- A bunch of other stuff related to Jenkins X and required for the `jx` commands, typically `jx preview` or `jx step git credentials`.
