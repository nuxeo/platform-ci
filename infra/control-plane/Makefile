include ../../.tmp/boot-secrets.mk
include ../../.tmp/boot-requirements.mk

pulumi-stack := helm-x

include ../make.d/env.mk
include ../make.d/pulumi.mk

-include config.mk

clean: npm-clean pulumi~clean; @:

update: pulumi~refresh pulumi~update ; @:
select: pulumi~select; @;
preview: pulumi~preview ; @:
refresh: pulumi~refresh ; @:
diff: pulumi~diff ; @:
rm: pulumi~rm ; @:
destroy: pulumi~destroy ; @:

