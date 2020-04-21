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

all/%: control-plane/% $(call sub-stacks-targets,%); @ echo $(*)
