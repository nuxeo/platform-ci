ifndef pulumi~mk

pulumi-mk := $(lastword $(MAKEFILE_LIST))

this-mk  := $(pulumi-mk)
this-dir := $(realpath $(dir $(this-mk)))
top-dir  := $(realpath $(this-dir)/..)

include $(this-dir)/macros.mk
include $(this-dir)/npm.mk

$(call check-variable-defined,pulumi-stack)

.PHONY: Pulumi.$(pulumi-stack).yaml
.PRECIOUS: Pulumi.$(pulumi-stack).yaml

Pulumi.$(pulumi-stack).yaml: pulumi~init pulumi~stack-config; @:

pulumi~login:
	@:$(call check-variable-defined,pulumi-token)
	@PULUMI_ACCESS_TOKEN=$(pulumi-token) pulumi --non-interactive login

pulumi~select: Pulumi.$(pulumi-stack).yaml
	pulumi stack select $(pulumi-stack)

pulumi~rm: pulumi~destroy
	pulumi --non-interactive --stack=$(pulumi-stack) stack rm --yes 

pulumi~graph: Pulumi.$(pulumi-stack).yaml
	pulumi --non-interactive --stack=$(pulumi-stack) stack graph graph.dot

pulumi~refresh: Pulumi.$(pulumi-stack).yaml
	pulumi --non-interactive --stack=$(pulumi-stack) refresh --yes --diff 

pulumi~diff: Pulumi.$(pulumi-stack).yaml
	pulumi --non-interactive --stack=$(pulumi-stack) preview --diff 

pulumi~update: Pulumi.$(pulumi-stack).yaml pulumi~refresh
	pulumi --non-interactive --stack=$(pulumi-stack) update --yes 


pulumi~destroy: Pulumi.$(pulumi-stack).yaml
	pulumi --non-interactive --stack=$(pulumi-stack) destroy --yes 

pulumi~clean: npm-clean; @:

pulumi~stack-config: ; @:

pulumi~stack-config: pulumi~gcp-config

pulumi~gcp-config:
	@:$(call check-variable-defined,gcp-project gcp-region gcp-zone)
	pulumi config set --plaintext --path gcp:project $(gcp-project)
	pulumi config set --plaintext --path gcp:region $(gcp-region)
	pulumi config set --plaintext --path gcp:zone $(gcp-zone)


pulumi~init: pulumi~init-pre.d pulumi~init-do pulumi~init-post.d; @:
pulumi~init-pre.d: | pulumi~login ; @:
pulumi~init-post.d: ; @:

pulumi~init-do: 
	test -n "$$(pulumi stack ls -j 2>/dev/null | jq '.[] | select (.name == "$(pulumi-stack)") | .name')" || \
	  pulumi --non-interactive stack init $(pulumi-stack)
	pulumi stack select $(pulumi-stack)
	pulumi --non-interactive --stack=$(pulumi-stack) stack tag set environment $(pulumi-stack)

endif
