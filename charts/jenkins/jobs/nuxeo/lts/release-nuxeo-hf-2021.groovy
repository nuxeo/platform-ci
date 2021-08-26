pipelineJob('nuxeo/lts/release-nuxeo-hf-2021') {
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
      scriptPath('Jenkinsfiles/release-hf.groovy')
    }
  }
  parameters {
    string {
      name('NUXEO_CURRENT_VERSION')
      defaultValue('')
      description('Nuxeo build version.')
      trim(true)
    }
  }
}