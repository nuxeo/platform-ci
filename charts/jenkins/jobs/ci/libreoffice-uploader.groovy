pipelineJob('ci/libreoffice-uploader') {
  // Description
  description('Job to download/upload Libreoffice.')
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
      scriptPath('Jenkinsfiles/libreoffice.groovy')
    }
  }
}