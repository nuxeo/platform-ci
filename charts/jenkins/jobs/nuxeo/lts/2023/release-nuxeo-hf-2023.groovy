pipelineJob('nuxeo/lts/2023/release-nuxeo-hf-2023') {
  // Description
  description('Promote a given Nuxeo hotfix package version as a release')
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
          branches('*/2023')
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
      scriptPath('Jenkinsfiles/release-hf.groovy')
    }
  }
  parameters {
    string {
      name('NUXEO_BUILD_VERSION')
      defaultValue('')
      description('Version of the promoted Nuxeo Server build.')
      trim(true)
    }
  }
}