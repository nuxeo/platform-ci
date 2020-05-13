export stack_make_template
define stack_make_template =
-include $$(boot-secrets-mk)
-include $$(boot-requirements-mk)

include ../make.d/env.mk
include ../make.d/pulumi.mk

-include config.mk

clean: npm-clean pulumi-clean; @:

update: pulumi~update ; @:
select: pulumi~select; @;
preview: pulumi~update ; @:
refresh: pulumi~refresh ; @:
diff: pulumi~diff ; @:
rm: pulumi~rm ; @:
destroy: pulumi~destroy ; @:

endef

%/Makefile:
	echo "$${stack_make_template}" > $(@)

makefiles: ; @:
