pipelineJob('nuxeo/lts/nuxeo-hf-2021') {
  // Description
  description('Continuous build of hotfix for nuxeo LTS 2021.')
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/integration-scripts-priv')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/2021')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/integration-scripts-priv')
            }
          }
        }
      }
      // Lightweight checkout
      lightweight(true)
      // Script Path
      scriptPath('Jenkinsfiles/build-hf.groovy')
    }
  }
}