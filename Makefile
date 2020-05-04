include make.d/env.mk
include make.d/macros.mk

export stack_make_template
define stack_make_template =
-include $$(boot-secrets-mk)
-include $$(boot-requirements-mk)

include ../make.d/env.mk
include ../make.d/pulumi.mk

ifneq (,$$(wildcard config.mk))
include config.mk
endif

clean:
	rm -fr nodes-modules _cacaches _locks node_modules
endef

export stack_package_json
define stack_package_json =
{
    "name": "jxlabs-nos-infra-$(name)",
    "main": "index.js",
    "dependencies": {
        "@pulumi/gcp": "^3.3.0",
        "@pulumi/pulumi": "^2.1.0",
        "@pulumi/kubernetes": "^2.0.0",
        "@pulumi/github": "^1.1.0"
    },
    "devDependencies": {
        "lint": "^0.7.0"
    }
}
endef

package.json: name:=main
package.json:
	echo "$${stack_package_json}" > $(@)

install: package.json
	npm install

%/package.json: name:=$(*)
%/package.json:
	echo "$${stack_package_json}" > $(@)

%/Makefile:
	echo "$${stack_make_template}" > $(@)

define stack-rule-template =
$(1)~%: $(1)/Makefile $(1)/package.json; $(MAKE) $(ifeq (,$(boot-secrets-mk)),,boot-secrets-mk=$(realpath $(boot-secrets-mk))) -C $(1) $$(*)
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

cluster~clean@dummy: clean all~clean@%; @:
cluster~update@%: all~init@% all~update@%; @:
cluster~preview@%: all~preview@%; @:
cluster~diff@%: all~diff@%; @:
cluster~destroy@%: all~destroy@% all~rm@%; @:

clean:
	rm -fr nodes-modules _cacaches _locks node_modules
