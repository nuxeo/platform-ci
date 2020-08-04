include make.d/env.mk
include make.d/macros.mk
include make.d/npm.mk

include stack-makefile.mk
include stack-package-json.mk

help: ## List the available targets
	 @awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z~_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# $(call check-variable-defined,infra-stack)

update: infra~update ## Update all the Pulumi stacks
refresh: infra~refresh ## Refresh all the Pulumi stacks
preview: infra~preview ## Preview all the Pulumi stacks
destroy: infra~destroy ## Destroy all the Pulumi stacks

infra~update: all~update | npm-install; @:
infra~refresh: all~refresh | npm-install; @:
infra~preview: all~preview | npm-install; @:
infra~destroy: all~destroy all~rm | npm-install; @:

define stack-rule-template =
$(eval .PRECIOUS: $(1)/Makefile)
$(eval .PRECIOUS: $(1)/package.json)
makefiles: $(1)/Makefile ## TODO
# makefiles: control-plane/Makefile builder-node-pool/Makefile
# see stack-makefile.mk -> makefiles: ; @:
# see stack-package-json.mk -> packages: ; @:
packages: $(1)/package.json ## TODO
clean: $(1)~clean ## TODO
$(1)~%: $(1)/Makefile $(1)/package.json; $(MAKE) -C $(1) pulumi-stack=$(infra-stack) $$*  ## TODO: describe $(1)
endef

define depends-on-control-plane =
$(if $(filter,control-plane,$(1)),,control-plane~update@
endef

define stack-rule =
$(eval $(call stack-rule-template,$(1)))
endef

# builder-node,pool,control-plane,...
stacks := $(subst /Pulumi.yaml,,$(wildcard */Pulumi.yaml))

$(foreach stack,$(stacks),$(call stack-rule,$(stack)))

define stack-rules =
$(1)~destroy: $(foreach stack,$(call reverse,$(2)),$(stack)~destroy); @:
$(1)~%: $(foreach stack,$(2),$(stack)~%); @:
endef

$(eval $(call stack-rules,k8s,control-plane builder-node-pool namespaces))
$(eval $(call stack-rules,keys,keyring vault))
#keys~destroy: vault~destroy keyring~destroy; @:
#keys~%: keyring~% vault~%; @:
# ex:
# keys~update: keyring~update vault~update; @:

$(eval $(call stack-rules,services,keys storage chart gcr kaniko dns))
$(eval $(call stack-rules,all,k8s services helmboot))
