pipelineJob('nuxeo/lts/release-nuxeo-2021') {
  // Description
  description('Promote a given Nuxeo Server build version as a release')
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
          branches('*/2021')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-lts')
            }
          }
        }
      }
      // Lightweight checkout
      lightweight(true)
      // Script Path
      scriptPath('ci/Jenkinsfiles/release.groovy')
    }
  }
}