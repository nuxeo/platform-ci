include make.d/env.mk
include make.d/macros.mk

export stack_make_template
define stack_make_template =
include ../make.d/env.mk
include ../make.d/pulumi.mk
endef

%/Makefile:
	echo "$${stack_make_template}" > $(@)

define stack-rule-template =
$(1)/%: $(1)/Makefile ; $(MAKE) -C $(1) $$(*)
endef

define depends-on-control-plane =
$(if $(filter,control-plane,$(1)),,control-plane/update@
endef

define stack-rule =
$(eval $(call stack-rule-template,$(1)))
endef

stacks := $(subst /Pulumi.yaml,,$(wildcard */Pulumi.yaml))

$(foreach stack,$(stacks),$(call stack-rule,$(stack)))

sub-stacks := $(filter-out control-plane,$(stacks))

define sub-stacks-targets =
$(foreach stack,$(sub-stacks),$(stack)/$(1))
endef


define stack-rules =
$(1)/destroy@%: $(foreach stack,$(call reverse,$(2)),$(stack)/destroy@%); @:
$(1)/%: $(foreach stack,$(2),$(stack)/%); @:
endef

$(eval $(call stack-rules,k8s,control-plane builder-node-pool helmboot kaniko dns))
$(eval $(call stack-rules,keyring,keyring vault))
$(eval $(call stack-rules,other,storage))
$(eval $(call stack-rules,all,k8s keyring other))
