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
    label 'jenkins-base'
  }
  environment {
    AWS_CREDENTIALS_SECRET = 'aws-credentials'
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
        container('base') {
          echo """
          ----------------------------------------------
          Upgrade Jenkins X Platform: Nexus, ChartMuseum
          Namespace: ${NAMESPACE}
          ----------------------------------------------"""
          dir('jenkins-x-platform') {
            echo "With jx we're stuck with Helm 2"
            echo 'Helm 2 version:'
            sh 'helm version'

            echo 'initialize Helm without installing Tiller'
            sh 'helm init --client-only --stable-repo-url=https://charts.helm.sh/stable'

            echo 'add local chart repository'
            sh 'helm repo add jenkins-x https://jenkins-x-charts.github.io/v2/'

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
          echo "Override Helm 2 with Helm 3 since `--helm-binary /usr/bin/helm3` doesn't seem to work in `helmfile deps`"
          sh 'mv /usr/bin/helm3 /usr/bin/helm'
          echo 'Helm 3 version:'
          sh 'helm version'

          echo 'Helmfile version:'
          sh 'helmfile version'

          echo 'synchronize cluster state'
          helmfileTemplate("${HELMFILE_ENVIRONMENT}", 'target')
          withCredentials([
            usernamePassword(credentialsId: 'packages.nuxeo.com-auth', usernameVariable: 'PACKAGES_USERNAME', passwordVariable: 'PACKAGES_PASSWORD'),
            usernamePassword(credentialsId: 'connect-prod', usernameVariable: 'CONNECT_USERNAME', passwordVariable: 'CONNECT_PASSWORD'),
          ]) {
            script {
              def awsAccessKeyId = sh(
                script: "kubectl get secret ${AWS_CREDENTIALS_SECRET} -n ${NAMESPACE} -o=jsonpath='{.data.access_key_id}' | base64 --decode",
                returnStdout: true
              )
              def awsSecretAccessKey = sh(
                script: "kubectl get secret ${AWS_CREDENTIALS_SECRET} -n ${NAMESPACE} -o=jsonpath='{.data.secret_access_key}' | base64 --decode",
                returnStdout: true
              )
              withEnv([
                  "AWS_ACCESS_KEY_ID=${awsAccessKeyId}",
                  "AWS_SECRET_ACCESS_KEY=${awsSecretAccessKey}"
                ]) {
                helmfileSync("${HELMFILE_ENVIRONMENT}")
              }
            }
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
        container('base') {
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
