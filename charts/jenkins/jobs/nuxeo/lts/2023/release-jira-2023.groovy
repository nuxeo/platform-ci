pipelineJob('nuxeo/lts/2023/release-jira-2023') {
  // Description
  description('Release a given Nuxeo Server version in JIRA')
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
      scriptPath('Jenkinsfiles/release-jira.groovy')
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