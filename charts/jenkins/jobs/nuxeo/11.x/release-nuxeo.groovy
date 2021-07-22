pipelineJob('nuxeo/11.x/release-nuxeo') {
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
            url('https://github.com/nuxeo/nuxeo')
            // Credentials
            credentials('github-branch-source')
          }
          // Branches to build
          branches('*/master')
          browser {
            // Repository browser
            githubWeb {
              // URL
              repoUrl('https://github.com/nuxeo/nuxeo')
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
  parameters {
    string {
      name('BUILD_VERSION')
      defaultValue('')
      description('Version of the Nuxeo Server build to promote')
      trim(true)
    }
  }
}