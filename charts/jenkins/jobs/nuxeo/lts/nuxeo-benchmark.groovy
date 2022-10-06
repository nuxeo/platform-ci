pipelineJob('nuxeo/lts/nuxeo-benchmark') {
  // Description
  description('Nuxeo Benchmark')
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/nuxeo-lts')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('^${NUXEO_BRANCH}')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-lts')
            }
          }
        }
      }
      // no lightweight checkout in order to make branch parameter work
      lightweight(false)
      // Script Path
      scriptPath('ci/Jenkinsfiles/benchmark.groovy')
    }
  }
  parameters {
    string {
      name('NUXEO_BRANCH')
      defaultValue('2021')
      description('Branch from which to retrieve pipeline definition and benchmark tests.')
      trim(true)
    }
    string {
      name('NUXEO_DOCKER_IMAGE')
      defaultValue('docker-private.packages.nuxeo.com/nuxeo/nuxeo:2021')
      description('Nuxeo Docker image to bench.')
      trim(true)
    }
    booleanParam {
      name('INSTALL_NEEDED_PACKAGES')
      defaultValue(true)
      description('Whether or not to install needed Nuxeo packages during Nuxeo startup')
    }
    string {
      name('NUXEO_NB_APP_NODE')
      defaultValue('1')
      description('Number of nuxeo app node.')
      trim(true)
    }
    string {
      name('NUXEO_NB_WORKER_NODE')
      defaultValue('1')
      description('Number of nuxeo worker node.')
      trim(true)
    }
    booleanParam {
      name('DEBUG')
      defaultValue(false)
      description('Whether or not to sleep before destroying the stack')
    }
  }
  properties {
    disableConcurrentBuilds {
      abortPrevious(false)
    }
  }
}