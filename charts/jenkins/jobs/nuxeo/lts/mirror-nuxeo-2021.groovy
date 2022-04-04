pipelineJob('nuxeo/lts/mirror-nuxeo-2021') {
  // Description
  description('Mirror the nuxeo/nuxeo-lts repository to nuxeo/nuxeo with a delay of 90 days.')
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
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/platform-ci-tools')
            }
          }
        }
      }
      // Lightweight checkout
      lightweight(true)
      // Script Path
      scriptPath('Jenkinsfiles/mirror-nuxeo-lts.groovy')
    }
  }
}