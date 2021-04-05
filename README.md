# Nuxeo Platform CI

Configuration as Code for the Platform CI.

## Jenkins

We rely on the [Jenkins Operator](https://github.com/jenkinsci/kubernetes-operator) to manage Jenkins in Kubernetes.

The operator is installed with [Helmfile](https://github.com/roboll/helmfile).

### Requirements

- [Helm 3](https://helm.sh/docs/intro/install/)
- [Helmfile](https://github.com/roboll/helmfile#installation)
- [Helm Diff plugin](https://github.com/databus23/helm-diff#install)
- [Kustomize](https://kubernetes-sigs.github.io/kustomize/installation/)

### Installation

Define the target namespace variable:

```shell
NAMESPACE=targetnamespace
```

Install the Jenkins Custom Resource Definition:

```shell
kubectl apply -f https://raw.githubusercontent.com/jenkinsci/kubernetes-operator/master/deploy/crds/jenkins_v1alpha2_jenkins_crd.yaml
```

Patch it to allow synchronizing and patching the Jenkins custom resource with `helmfile`:

```shell
kubectl patch crd jenkins.jenkins.io --patch "$(NAMESPACE=$NAMESPACE envsubst < charts/jenkins-operator/patches/jenkins-crd.yaml)"
kubectl patch crd jenkinsimages.jenkins.io --patch "$(NAMESPACE=$NAMESPACE envsubst < charts/jenkins-operator/patches/jenkins-crd.yaml)"
```

Otherwise, we get the following error when running `helmfile sync`:

> Error: UPGRADE FAILED: rendered manifests contain a resource that already exists. Unable to continue with update: CustomResourceDefinition "jenkins.jenkins.io" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "jenkins-operator"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "$NAMESPACE"

Create the `$NAMESPACE` namespace and import the required secrets from the `platform-staging` or `platform` namespace:

```shell
kubectl create ns $NAMESPACE

kubectl get secret platform-staging-tls --namespace=platform-staging --export -o yaml |\
   kubectl apply --namespace=$NAMESPACE -f -

kubectl get secret kubernetes-docker-cfg --namespace=platform-staging --export -o yaml |\
   kubectl apply --namespace=$NAMESPACE -f -

kubectl get secret jx-pipeline-git-github-git --namespace=platform-staging --export -o yaml |\
   kubectl apply --namespace=$NAMESPACE -f -

kubectl get secret kaniko-secret --namespace=platform-staging --export -o yaml |\
   kubectl apply --namespace=$NAMESPACE -f -

kubectl get secret packages.nuxeo.com-auth --namespace=platform-staging --export -o yaml |\
   kubectl apply --namespace=$NAMESPACE -f -

(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: jenkins-docker-cfg
data:
  config.json: ********
EOF
) | kubectl apply --namespace=$NAMESPACE -f -

(
cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: jenkins-casc
data:
  GITHUB_OAUTH_CLIENT_ID: ********
  GITHUB_OAUTH_SECRET: ********
  GITHUB_USER: ********
  GITHUB_TOKEN: ********
  JIRA_PASSWORD: ********
  SLACK_TOKEN: ********
EOF
) | kubectl apply --namespace=$NAMESPACE -f -

(
cat << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: platform:jenkins-operator-master
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins-operator-master
  namespace: $NAMESPACE
EOF
) | kubectl apply -f -
```

Sync all resources from the [state file](./helmfile.yaml):

```shell
helmfile sync
```

Have fun using [Jenkins](https://jenkins.$NAMESPACE.dev.nuxeo.com/).
