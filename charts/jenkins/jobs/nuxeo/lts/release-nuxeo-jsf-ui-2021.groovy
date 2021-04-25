pipelineJob('nuxeo/lts/release-nuxeo-jsf-ui-2021') {
  // Description
  description('Release Nuxeo JSF UI')
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/nuxeo-jsf-ui-lts')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/2021')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-jsf-ui-lts')
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