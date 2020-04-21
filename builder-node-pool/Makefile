owner := nxmatic

export pulumi_shared_config
define pulumi_shared_config :=
config:
  gcp:project: build-jx-prod
  gcp:region: us-east1
  gcp:zone: us-east1-b
  jxlabs-nos-infra-builder-node-pool:nodePool:
    enabled: true
endef

init@%:
	pulumi stack init $(owner)/$(*)

rm@%: 
	pulumi stack rm --stack=$(*)

select@%:
	pulumi stack select $(*)

diff@%: Pulumi.%.yaml
	pulumi --non-interactive preview --refresh --diff --stack=$(*)

update@%: Pulumi.%.yaml
	pulumi --non-interactive update --yes --refresh --stack=$(*)

destroy@%:
	pulumi --non-interactive destroy --stack=$(*)

Pulumi.%.yaml: 
	echo "$${pulumi_shared_config}" > ${@}
