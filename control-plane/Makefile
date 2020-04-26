include ../make.d/env.mk
include ../make.d/pulumi.mk

override define pulumi_shared_config :=
config:
  gcp:project: build-jx-prod
  gcp:region: us-east1
  gcp:zone: us-east1-b
  jxlabs-nos-infra-builder-node-pool:nodePool:
    enabled: true
endef
