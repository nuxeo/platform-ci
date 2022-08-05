# Nuxeo Platform CI

Configuration as code for the Nuxeo Platform CI in Kubernetes.

## Principles

### Jenkins

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

### Nexus

Nexus is used as:

- An internal Docker [registry](https://docker.platform.dev.nuxeo.com/) for the images built by Kaniko in the Jenkins pipelines.
- An internal Maven proxy [repository](https://nexus.platform.dev.nuxeo.com/repository/maven-upstream/) to the main upstream [repository](https://packages.nuxeo.com/repository/maven-internal-build/).

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

Create the secret containing the Nexus credentials:

```shell
(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
data:
  password: ********
  username: ********
metadata:
  annotations:
    meta.helm.sh/release-name: nexus
    meta.helm.sh/release-namespace: $NAMESPACE
  labels:
    app.kubernetes.io/instance: nexus
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: nexus
    helm.sh/chart: nexus-0.1.41
    jenkins.io/credentials-type: usernamePassword
  name: nexus
EOF
) | kubectl apply --namespace=$NAMESPACE -f -
```

Create the secret containing the Chartmuseum credentials:

```shell
(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
data:
  BASIC_AUTH_PASS: ********
  BASIC_AUTH_USER: ********
metadata:
  annotations:
    meta.helm.sh/release-name: chartmuseum
    meta.helm.sh/release-namespace: $NAMESPACE
  labels:
    app.kubernetes.io/instance: chartmuseum
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: chartmuseum
    helm.sh/chart: chartmuseum-1.1.7
    jenkins.io/credentials-type: usernamePassword
  name: chartmuseum
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

Create the secret containing the Datadog API Key:

```shell
(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
data:
  api-key: ********
metadata:
  annotations:
    meta.helm.sh/release-name: datadog
    meta.helm.sh/release-namespace: $NAMESPACE
  labels:
    app.kubernetes.io/managed-by: Helm
  name: datadog-nxio-api
EOF
) | kubectl apply --namespace=$NAMESPACE -f -
```

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

- Credentials for [nexus.platform.dev.nuxeo.com](https://nexus.platform.dev.nuxeo.com/) or [nexus.platform-staging.dev.nuxeo.com](https://nexus.platform-staging.dev.nuxeo.com/):
  - `NEXUS_USERNAME`
  - `NEXUS_PASSWORD`

- Credentials for [chartmuseum.platform.dev.nuxeo.com](https://chartmuseum.platform.dev.nuxeo.com/) or [chartmuseum.platform-staging.dev.nuxeo.com](https://chartmuseum.platform-staging.dev.nuxeo.com/):
  - `CHARTMUSEUM_USERNAME`
  - `CHARTMUSEUM_PASSWORD`

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
