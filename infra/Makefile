include make.d/env.mk
include make.d/macros.mk
include make.d/npm.mk

include stack-makefile.mk
include stack-package-json.mk


$(call check-variable-defined,infra-stack)

update: infra~update
refresh: infra~refresh
preview: infra~preview
destroy: infra~destroy

infra~update: all~update | node_modules; @:
infra~refresh: all~refresh | node_modules; @:
infra~preview: all~preview | node_modules; @:
infra~destroy: all~destroy all~rm | node_modules; @:

define stack-rule-template =
$(eval .PRECIOUS: $(1)/Makefile)
$(eval .PRECIOUS: $(1)/package.json)
makefiles: $(1)/Makefile
packages: $(1)/package.json
clean: $(1)~clean
$(1)~%: $(1)/Makefile $(1)/package.json; $(MAKE) -C $(1) pulumi-stack=$(infra-stack) $$*
endef

define depends-on-control-plane =
$(if $(filter,control-plane,$(1)),,control-plane~update@
endef

define stack-rule =
$(eval $(call stack-rule-template,$(1)))
endef

stacks := $(subst /Pulumi.yaml,,$(wildcard */Pulumi.yaml))

$(foreach stack,$(stacks),$(call stack-rule,$(stack)))

define stack-rules =
$(1)~destroy: $(foreach stack,$(call reverse,$(2)),$(stack)~destroy); @:
$(1)~%: $(foreach stack,$(2),$(stack)~%); @:
endef

$(eval $(call stack-rules,k8s,control-plane builder-node-pool namespaces))
$(eval $(call stack-rules,keys,keyring vault))
$(eval $(call stack-rules,services,keys storage chart gcr kaniko dns))
$(eval $(call stack-rules,all,k8s services helmboot))
