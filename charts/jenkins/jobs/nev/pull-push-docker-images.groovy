pipelineJob('nev/pull-push-docker-image') {
  // Description
  description('Push Docker Images to Openshift')
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/platform-ci-tools')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/main')
        }
      }
      // Lightweight checkout
      lightweight(true)
      // Script Path
      scriptPath('Jenkinsfiles/nev/pull-push-docker-images.groovy')
    }
  }
  parameters {
    string {
      name('NEV_VERSION')
      defaultValue('1.0.0')
      description('The NEV version to pull/push')
      trim(true)
    }
    choice {
      name('FROM_REGISTRY')
      choices(['docker-arender.packages.nuxeo.com', 'docker.platform.dev.nuxeo.com'])
      description('The Docker registry to pull images')
    }
    choice {
      name('TO_CLUSTER')
      choices(['*', 'io',  'va', 'oh'])
      description('The Openshift cluster to push images')
    }
    booleanParam {
      name('LEGACY')
      defaultValue(false)
      description('Whether or not the version to pull/push is before the repository split.')
    }
  }
}