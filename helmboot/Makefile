-include $(boot-secrets-mk)
-include $(boot-requirements-mk)

include ../make.d/env.mk
include ../make.d/pulumi.mk

ifneq (,$(wildcard config.mk))
include config.mk
endif

clean:
	rm -fr nodes-modules _cacaches _locks node_modules
