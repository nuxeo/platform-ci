pipelineJob('explorer/trigger-export-on-build') {
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
      scriptPath('ci/Jenkinsfiles/trigger-export-on-build.groovy')
    }
  }
  properties {
    pipelineTriggers {
      triggers {
        upstream {
          upstreamProjects('/nuxeo/11.x/nuxeo/master')
          threshold('SUCCESS')
        }
      }
    }
  }
}