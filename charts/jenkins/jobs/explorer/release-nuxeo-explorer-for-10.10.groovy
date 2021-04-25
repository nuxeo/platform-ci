pipelineJob('explorer/release-nuxeo-explorer-for-10.10') {
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/nuxeo-explorer')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/18.0_10.10')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-explorer')
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