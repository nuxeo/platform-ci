pipelineJob('explorer/customers/trigger-exports') {
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/nuxeo-explorer-customers')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/feat-SUPINT-1863-init-export-logic')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-explorer-customers')
            }
          }
        }
      }
      // Lightweight checkout
      lightweight(true)
      // Script Path
      scriptPath('ci/Jenkinsfiles/trigger-exports.groovy')
    }
  }
}