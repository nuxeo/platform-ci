.PHONY: .tmp/boot-git-url.mk
.PRECIOUS: .tmp/boot-git-url.mk

.tmp/boot-git-url.mk: | .tmp
	@echo "export boot-git-url := $(kubectl get secrets/jx-boot-git-url -o jsonpath='{.data.git-url}' | base64 -d)" > .tmp/boot-git-url.mk

-include .tmp/boot-git-url.mk
