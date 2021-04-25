pipelineJob('nuxeo-sample-multi-projects/release-final2') {
  definition {
    // Definition
    cpsScm {
      scm {
        // SCM
        git {
          // Repositories
          remote {
            // Repository URL
            url('https://github.com/nuxeo/nuxeo-sample-multi-final2')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/master')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo-sample-multi-final2')
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