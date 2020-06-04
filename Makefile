include make.d/boot.mk

.tmp:
	@mkdir .tmp

clean: boot~clean
	rm -fr .tmp

