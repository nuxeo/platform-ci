/*
 * (C) Copyright 2021 Nuxeo (http://nuxeo.com/) and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors:
 *     Antoine Taillefer <ataillefer@nuxeo.com>
 */
 properties([
  [$class: 'GithubProjectProperty', projectUrlStr: 'https://github.com/nuxeo/platform-ci/'],
  [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', daysToKeepStr: '60', numToKeepStr: '60', artifactNumToKeepStr: '5']],
  disableConcurrentBuilds(),
])

void setGitHubBuildStatus(String context, String message, String state) {
  step([
    $class: 'GitHubCommitStatusSetter',
    reposSource: [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/nuxeo/platform-ci'],
    contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: context],
    statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]]],
  ])
}

String getReleaseVersion() {
  return sh(returnStdout: true, script: 'jx-release-version')
}

def isStaging() {
  return BRANCH_NAME =~ /PR-.*/ || env.DRY_RUN == 'true'
}

def getTargetNamespace() {
  return isStaging() ? 'platform-staging' : 'platform'
}

def getHelmfileEnvironment() {
  return isStaging() ? 'default' : 'production'
}

void helmfileTemplate(environment, outputDir) {
  sh """
    helmfile deps
    helmfile --environment ${environment} template --output-dir ${outputDir}
  """
}

void helmfileSync(environment) {
  sh """
    helmfile deps
    helmfile --environment ${environment} sync
  """
}

pipeline {
  agent {
    label 'jenkins-jx-base'
  }
  environment {
    JX_VERSION = '2.0.2412'
    HELM2_VERSION = '2.16.6'
    HELM3_VERSION = '3.5.3'
    NAMESPACE = getTargetNamespace()
    HELMFILE_ENVIRONMENT = getHelmfileEnvironment()
  }
  stages {
    stage('Update CI') {
      steps {
        setGitHubBuildStatus('update-ci', 'Update Platform CI', 'PENDING')
        container('jx-base') {
          echo """
          ----------------------------------------------
          Upgrade Jenkins X Platform: Nexus, ChartMuseum
          Namespace: ${NAMESPACE}
          ----------------------------------------------"""
          dir('jenkins-x-platform') {
            // install a more recent version of Helm 2 for Helm to correctly detect the API version capabilities
            // of the server in the chart manifests:
            // {{- if .Capabilities.APIVersions.Has "apps/v1" }}
            // apiVersion: apps/v1
            // {{- else }}
            // apiVersion: apps/v1beta1
            // {{- end }}
            echo 'Current Helm 2 version:'
            sh 'helm version'

            sh 'wget -qO - https://get.helm.sh/helm-v$HELM2_VERSION-linux-amd64.tar.gz | tar -xzvf - --strip-components=1 -C /usr/bin linux-amd64/helm'
            echo 'New Helm 2 version:'
            sh 'helm version'

            // with jx we're stuck with Helm 2
            echo 'initialize Helm without installing Tiller'
            sh 'helm init --client-only --stable-repo-url=https://charts.helm.sh/stable'

            echo 'add local chart repository'
            sh 'helm repo add jenkins-x http://chartmuseum.jenkins-x.io'

            echo 'create or update Docker Ingress/Service'
            sh '''
              envsubst < templates/docker-service.yaml > templates/docker-service.yaml~gen
              kubectl apply -f templates/docker-service.yaml~gen
            '''

            echo 'jx version:'
            sh 'jx version --no-verify=true --no-version-check=true'

            echo 'upgrade Jenkins X Platform'
            withCredentials([string(credentialsId: 'jenkins-docker-cfg', variable: 'DOCKER_REGISTRY_CONFIG')]) {
              sh 'envsubst < values.yaml > myvalues.yaml'
            }
            sh """
              jx upgrade platform --namespace=${NAMESPACE} \
                --version ${JX_VERSION} \
                --local-cloud-environment \
                --always-upgrade \
                --cleanup-temp-files=true \
                --batch-mode
            """

            echo 'disable unwanted gc cron jobs'
            sh """
              kubectl --namespace=${NAMESPACE} delete cronjob jenkins-x-gcactivities
              kubectl --namespace=${NAMESPACE} delete cronjob jenkins-x-gcpods
            """
          }

          echo """
          ----------------------------------------------------------------------
          Synchronize K8s cluster state with Helmfile: Jenkins
          Namespace: ${NAMESPACE}
          ----------------------------------------------------------------------"""
          echo 'Current Helm 3 version:'
          sh 'helm3 version'

          // get a recent version of Helm3 since Helmfile requires it
          // override Helm 2 with Helm 3 since `--helm-binary /usr/bin/helm3` doesn't seem to work in `helmfile deps`
          sh '''
            wget -qO - https://get.helm.sh/helm-v$HELM3_VERSION-linux-amd64.tar.gz \
             | tar -xzvf - --strip-components=1 -C /usr/bin linux-amd64/helm
          '''
          echo 'New Helm 3 version:'
          sh 'helm version'

          echo 'install Helmfile'
          sh '''
            wget -q -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.138.7/helmfile_linux_amd64
            chmod +x /usr/local/bin/helmfile
          '''

          echo 'install Kustomize'
          sh '''
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
            mv kustomize /usr/bin/kustomize
          '''

          echo 'synchronize cluster state'
          withCredentials([
            usernamePassword(credentialsId: 'packages.nuxeo.com-auth', usernameVariable: 'PACKAGES_USERNAME', passwordVariable: 'PACKAGES_PASSWORD'),
            usernamePassword(credentialsId: 'connect-prod', usernameVariable: 'CONNECT_USERNAME', passwordVariable: 'CONNECT_PASSWORD'),
          ]) {
            helmfileTemplate("${HELMFILE_ENVIRONMENT}", 'target')
            helmfileSync("${HELMFILE_ENVIRONMENT}")
          }
        }
      }
      post {
        always {
          archiveArtifacts allowEmptyArchive: true, artifacts: 'helmfile.lock, target/**/*.yaml'
        }
        success {
          setGitHubBuildStatus('update-ci', 'Update Platform CI', 'SUCCESS')
        }
        failure {
          setGitHubBuildStatus('update-ci', 'Update Platform CI', 'FAILURE')
        }
      }
    }
    stage('Git release') {
      when {
        branch 'master'
      }
      steps {
        setGitHubBuildStatus('git-release', 'Perform Git release', 'PENDING')
        container('jx-base') {
          withEnv(["VERSION=${getReleaseVersion()}"]) {
            sh """
              # ensure we're not on a detached head
              git checkout master

              # create the Git credentials
              jx step git credentials
              git config credential.helper store

              # Git tag
              jx step tag -v ${VERSION}
            """
          }
        }
      }
      post {
        always {
          step([$class: 'JiraIssueUpdater', issueSelector: [$class: 'DefaultIssueSelector'], scm: scm])
        }
        success {
          setGitHubBuildStatus('git-release', 'Perform Git release', 'SUCCESS')
        }
        failure {
          setGitHubBuildStatus('git-release', 'Perform Git release', 'FAILURE')
        }
      }
    }
  }
}
