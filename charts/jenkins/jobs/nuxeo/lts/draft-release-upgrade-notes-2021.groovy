pipelineJob('nuxeo/lts/draft-release-upgrade-notes-2021') {
  // Description
  description('Draft release and upgrade notes for a Nuxeo Server released version')
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
      scriptPath('Jenkinsfiles/draft-release-upgrade-notes.groovy')
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