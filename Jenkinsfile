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
library identifier: "platform-ci-shared-library@v0.0.40"

def isStaging() {
  return nxUtils.isPullRequest() || nxUtils.isDryRun()
}

def getTargetNamespace() {
  return isStaging() ? 'platform-staging' : 'platform'
}

def getHelmfileEnvironment() {
  return isStaging() ? 'default' : 'production'
}

pipeline {
  agent {
    label 'jenkins-base'
  }
  options {
    buildDiscarder(logRotator(daysToKeepStr: '60', numToKeepStr: '60', artifactNumToKeepStr: '5'))
    disableConcurrentBuilds(abortPrevious: true)
    githubProjectProperty(projectUrlStr: 'https://github.com/nuxeo/platform-ci')
  }
  environment {
    NEXUS_SECRET = 'nexus'
    CHARTMUSEUM_SECRET = 'chartmuseum'
    AWS_CREDENTIALS_SECRET = 'aws-credentials'
    NAMESPACE = getTargetNamespace()
    HELMFILE_ENVIRONMENT = getHelmfileEnvironment()
  }
  stages {
    stage('Set labels') {
      steps {
        container('base') {
          script {
            nxK8s.setPodLabels()
          }
        }
      }
    }
    stage('Update CI') {
      steps {
        container('base') {
          nxWithGitHubStatus(context: 'update-ci', message: 'Update Platform CI') {
            script {
              echo """
              ----------------------------------------------------------------------
              Synchronize K8s cluster state with Helmfile: Jenkins
              Namespace: ${NAMESPACE}
              ----------------------------------------------------------------------"""
              echo 'Helmfile version:'
              sh 'helmfile version'

              echo 'synchronize cluster state'
              nxHelmfile.template(noNamespace: true, environment: env.HELMFILE_ENVIRONMENT, outputDir: 'target')
              withCredentials([
                usernamePassword(credentialsId: 'packages.nuxeo.com-auth', usernameVariable: 'PACKAGES_USERNAME', passwordVariable: 'PACKAGES_PASSWORD'),
                usernamePassword(credentialsId: 'connect-prod', usernameVariable: 'CONNECT_USERNAME', passwordVariable: 'CONNECT_PASSWORD'),
              ]) {
                // not using usernamePassword since we need to fetch credentials from the target namespace, e.g. platform-staging if on a PR
                def nexusUsername = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.NEXUS_SECRET, key: 'admin\\.username')
                def nexusPassword = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.NEXUS_SECRET, key: 'admin\\.password')
                def chartmuseumUsername = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.CHARTMUSEUM_SECRET, key: 'BASIC_AUTH_USER')
                def chartmuseumPassword = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.CHARTMUSEUM_SECRET, key: 'BASIC_AUTH_PASS')
                // not using usernamePassword to avoid displaying the access key id in the Jenkins credentials view
                def awsAccessKeyId = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.AWS_CREDENTIALS_SECRET, key: 'access_key_id')
                def awsSecretAccessKey = nxK8s.getSecretData(namespace: env.NAMESPACE, name: env.AWS_CREDENTIALS_SECRET, key: 'secret_access_key')
                nxHelmfile.deploy(noNamespace: true, environment: env.HELMFILE_ENVIRONMENT, envVars: [
                  "NEXUS_USERNAME=${nexusUsername}",
                  "NEXUS_PASSWORD=${nexusPassword}",
                  "CHARTMUSEUM_USERNAME=${chartmuseumUsername}",
                  "CHARTMUSEUM_PASSWORD=${chartmuseumPassword}",
                  "AWS_ACCESS_KEY_ID=${awsAccessKeyId}",
                  "AWS_SECRET_ACCESS_KEY=${awsSecretAccessKey}",
                ])
              }
            }
          }
        }
      }
      post {
        always {
          archiveArtifacts allowEmptyArchive: true, artifacts: 'helmfile.lock, target/**/*.yaml'
        }
      }
    }
    stage('Git release') {
      when {
        branch 'master'
      }
      environment {
        VERSION = nxUtils.getVersion()
      }
      steps {
        container('base') {
          nxWithGitHubStatus(context: 'git-release', message: 'Perform Git release') {
            script {
              // ensure we're not on a detached head
              sh "git checkout master"
              nxGit.tagPush()
            }
          }
        }
      }
      post {
        always {
          script {
            nxJira.updateIssues()
          }
        }
      }
    }
  }
}
