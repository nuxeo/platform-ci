include boot.mk
include helmfile.mk

.tmp:
	@mkdir .tmp

clean: boot~clean
	rm -fr .tmp

