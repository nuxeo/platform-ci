pipelineJob('nuxeo/lts/publish-nuxeo-hf-release-notes-2021') {
  // Description
  description('Update Hotfix package description with the JIRA release notes.')
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
      scriptPath('Jenkinsfiles/publish-hf-release-notes.groovy')
    }
  }
  parameters {
    string {
      name('HF_NUMBER')
      defaultValue('')
      description('A specific HF number (leave blank for latest HF).')
      trim(true)
    }
    string {
      name('NUXEO_BUILD_NUMBER')
      defaultValue('')
      description('Nuxeo build number, e.g. 2021.8.5')
      trim(true)
    }
  }
}