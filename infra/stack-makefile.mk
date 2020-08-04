export stack_make_template
define stack_make_template =
include ../../.tmp/boot-secrets.mk
include ../../.tmp/boot-requirements.mk

pulumi-stack := $(infra-stack)
# evaluated when exported/defined?

include ../make.d/env.mk
include ../make.d/pulumi.mk

-include config.mk

clean: npm-clean pulumi~clean; @:

update: pulumi~refresh pulumi~update ; @:
select: pulumi~select; @;
preview: pulumi~preview ; @:
refresh: pulumi~refresh ; @:
rm: pulumi~rm ; @:
destroy: pulumi~destroy ; @:

endef

%/Makefile:
	echo "$${stack_make_template}" > $@
	# $@ matches control-plane/Makefile
	# $* would only match control-plane

makefiles: ; @:

# idem:
#makefiles:
#	@:
