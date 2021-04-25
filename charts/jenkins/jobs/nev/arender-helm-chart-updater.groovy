pipelineJob('nev/arender-helm-chart-updater') {
  // Description
  description('Update ARender Helm chart')
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/arender-helm-chart')
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
      scriptPath('ci/Jenkinsfiles/arender-helm-chart-updater.groovy')
    }
  }
}