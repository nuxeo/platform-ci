-include $(boot-secrets-mk)
-include $(boot-requirements-mk)

include ../make.d/env.mk
include ../make.d/pulumi.mk

ifneq (,$(wildcard config.mk))
include config.mk
endif

clean: pulumi-clean; @:

pulumi-init-post.d@%: npm-install

update@%: pulumi-update@% ; @:
select@%: pulumi-select@%; @;
preview@%: pulumi-update@% ; @:
refresh@%: pulumi-refresh@% ; @:
diff@%: pulumi-diff@% ; @:
rm@%: pulumi-rm@% ; @:
destroy@%: pulumi-destroy@% ; @:

