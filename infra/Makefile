include make.d/env.mk
include make.d/macros.mk
include make.d/npm.mk

include stack-makefile.mk
include stack-package-json.mk

-include $$(boot-secrets-mk)
-include $$(boot-requirements-mk)

update@%: all~update@% | node-modules; @:
refresh@%: all~refresh@% | node-modules; @:
preview@%: all~preview@% | node-modules; @:
diff@%: all~diff@% | node-modules; @:
destroy@%: all~destroy@% all~rm@% | node-modules; @:

define stack-rule-template =
$(eval .PRECIOUS: $(1)/Makefile)
$(eval .PRECIOUS: $(1)/package.json)
makefiles: $(1)/Makefile
clean: $(1)~clean
$(1)~%: $(1)/Makefile $(1)/package.json; $(MAKE) -C $(1) $$(*)
endef

define depends-on-control-plane =
$(if $(filter,control-plane,$(1)),,control-plane~update@
endef

define stack-rule =
$(eval $(call stack-rule-template,$(1)))
endef

stacks := $(subst /Pulumi.yaml,,$(wildcard */Pulumi.yaml))

$(foreach stack,$(stacks),$(call stack-rule,$(stack)))

sub-stacks := $(filter-out control-plane,$(stacks))

define sub-stacks-targets =
$(foreach stack,$(sub-stacks),$(stack)~$(1))
endef


define stack-rules =
$(1)~destroy@%: $(foreach stack,$(call reverse,$(2)),$(stack)~destroy@%); @:
$(1)~%: $(foreach stack,$(2),$(stack)~%); @:
endef

$(eval $(call stack-rules,k8s,control-plane builder-node-pool helmboot kaniko dns))
$(eval $(call stack-rules,keys,keyring vault))
$(eval $(call stack-rules,other,storage))
$(eval $(call stack-rules,all,k8s keys other))

