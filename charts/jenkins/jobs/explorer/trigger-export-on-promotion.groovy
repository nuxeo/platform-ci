pipelineJob('explorer/trigger-export-on-promotion') {
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
          branches('*/master')
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
      scriptPath('ci/Jenkinsfiles/trigger-export-on-promotion.groovy')
    }
  }
  properties {
    pipelineTriggers {
      triggers {
        upstream {
          upstreamProjects('/nuxeo/lts/release-nuxeo-jsf-ui-2021')
          threshold('SUCCESS')
        }
      }
    }
  }
}