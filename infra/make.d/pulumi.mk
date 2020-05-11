ifndef pulumi-mk

pulumi-mk := $(lastword $(MAKEFILE_LIST))

this-mk  := $(pulumi-mk)
this-dir := $(realpath $(dir $(this-mk)))
top-dir  := $(realpath $(this-dir)/..)

include $(this-dir)/macros.mk
include $(this-dir)/npm.mk

$(call check-variable-defined,git-owner)

pulumi-login:
	@:$(call check-variable-defined,pulumi-token)
	@PULUMI_ACCESS_TOKEN=$(pulumi-token) pulumi --non-interactive login

pulumi-select@%: Pulumi.%.yaml
	pulumi stack select $(*)

pulumi-rm@%: pulumi-destroy@%
	pulumi --non-interactive --stack=$(*) stack rm --yes 

pulumi-graph@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) stack graph graph.dot

pulumi-refresh@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) refresh --yes --diff 

pulumi-diff@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) preview --diff 

pulumi-update@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) update --yes 


pulumi-destroy@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) destroy --yes 

pulumi-clean: npm-clean; @:

pulumi-stack-config: ; @:

pulumi-stack-config: pulumi-gcp-config

pulumi-gcp-config:
	@:$(call check-variable-defined,gcp-project gcp-region gcp-zone)
	pulumi config set --plaintext --path gcp:project $(gcp-project)
	pulumi config set --plaintext --path gcp:region $(gcp-region)
	pulumi config set --plaintext --path gcp:zone $(gcp-zone)

# use stack rule pattern, needed for ordering pre-requisites

.PRECIOUS: Pulumi.$(git-owner).yaml

Pulumi.$(git-owner).yaml: Pulumi.%.yaml: pulumi-init@% pulumi-stack-config; @:

pulumi-init@$(git-owner): pulumi-init@%: pulumi-init-pre.d@% pulumi-init-do@% pulumi-init-post.d@%; @:
pulumi-init-pre.d@$(git-owner): pulumi-init-pre.d@%: | pulumi-login ; @:
pulumi-init-post.d@$(git-owner): pulumi-init-post.d@%: ; @:

pulumi-init-do@%: 
	test -n "$$(pulumi stack ls -j 2>/dev/null | jq '.[] | select (.name == "$(*)") | .name')" || pulumi --non-interactive stack init $(*)
	pulumi stack select $(*)
	pulumi --non-interactive --stack=$(*) stack tag set environment $(*)

endif
