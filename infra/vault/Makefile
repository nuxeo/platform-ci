include ../../.tmp/boot-secrets.mk
include ../../.tmp/boot-requirements.mk

pulumi-stack := master

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

