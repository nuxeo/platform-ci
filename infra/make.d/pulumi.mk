pulumi-install@%: install; @:

pulumi-login: PULUMI_TOKEN ?= $(cat /run/secrets/pulumi/token)
pulumi-login:
	pulumi --non-interactive login

# use stack rule pattern, needed for ordering pre-requisites
git-owners ?= $(git-owner)

define pulumi-owners-target =
$(foreach owner,$(git-owners),$(1)@$(owner))
endef

Pulumi.%.yaml: pulumi-init@% pulumi-stack-config; @:


$(call pulumi-owners-target,pulumi-init): pulumi-init@%: pulumi-init-pre.d@% pulumi-init-do@% pulumi-init-post.d@%; @:

pulumi-init-do@%: 
	test -n "$$(pulumi stack ls -j 2>/dev/null | jq '.[] | select (.name == "$(*)") | .name')" || pulumi --non-interactive stack init $(*)

pulumi-init-post.d@%: pulumi-tag.environment@% ; @:

pulumi-init-pre.d@%: | install login
pulumi-init-pre.d@%: ; @:

pulumi-tag.environment@%:
	pulumi --non-interactive --stack=$(*) stack tag set environment $(*)

pulumi-rm@%: pulumi-destroy@%
	pulumi --non-interactive --stack=$(*) stack rm --yes 

pulumi-select@%: 
	pulumi stack select $(*)

pulumi-graph@%: 
	pulumi --non-interactive --stack=$(*) stack graph graph.dot

pulumi-refresh@%: 
	pulumi --non-interactive --stack=$(*) refresh --yes --diff 

pulumi-diff@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) preview --diff 

pulumi-update@%: pulumi-init@% Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) update --yes 


pulumi-destroy@%:
	pulumi --non-interactive --stack=$(*) destroy --yes 


pulumi-stack-config: ; @:

pulumi-stack-config: pulumi-gcp-config

pulumi-gcp-config:
	@:$(call check-variable-defined,gcp-project gcp-region gcp-zone)
	pulumi config set --plaintext --path gcp:project $(gcp-project)
	pulumi config set --plaintext --path gcp:region $(gcp-region)
	pulumi config set --plaintext --path gcp:zone $(gcp-zone)
