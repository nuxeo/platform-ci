export pulumi_config
define pulumi_config =
config:
$(call pulumi-shared-config)
$(if $(filter undefined,$(origin pulumi-stack-config)),,$(call pulumi-stack-config))
endef

define pulumi-shared-config =
  gcp:project: build-jx-prod
  gcp:region: us-east1
  gcp:zone: us-east1-b
endef

install: 
	npm install -m --no-packages-lock
	
init@%: init.pre.d@% init.do@% init.post.d@%; @:

init.do@%: 
	pulumi --non-interactive stack init $(*)

init.post.d@%: ; @:

init.pre.d@%: ; @:

tag.environment@%: 
	pulumi --non-interactive --stack=$(*) stack tag set environment $(*)


rm@%:
	pulumi --non-interactive --stack=$(*) stack rm --yes 

select@%:
	pulumi stack select $(*)

diff@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) preview --refresh --diff 

update@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) update --yes --refresh 

destroy@%:
	pulumi --non-interactive --stack=$(*) destroy --yes 

Pulumi.%.yaml:
	echo "$${pulumi_config}" > ${@}
