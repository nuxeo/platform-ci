# load pr labels if any

is-pull-request := $(shell expr "$(BRANCH_NAME)" : 'PR-*' > /dev/null && echo 'true' || echo 'false')

pull-request-labels:
ifeq ($(is-pull-request), true)
$(eval  $(shell jx step pr labels --batch-mode 2>/dev/null | awk -F= '{ printf "$$(eval export %s := %s)", $$1, $$2 }'))
endif

groovy-pull-request-labels: ## serialize pull request labels as a groovy map
groovy-pull-request-labels:
	@$(if $(filter 'true', $(is-pull-request)), :, jx step pr labels --batch-mode 2>/dev/null | awk -F= 'BEGIN { print "[" } { printf "%s:%s,\n", $$1, $$2; } END { print "]" }')

yaml-pull-request-labels: ## serialize pull request labels as a yaml env map
yaml-pull-request-labels:
	@$(if $(filter 'true', $(is-pull-request)), :, jx step pr labels --batch-mode 2>/dev/null | awk -F= 'BEGIN { print "env:" } { printf "- name: '%s'\n  value: %s\n", $$1, $$2; }')

.PHONY: groovy-pull-request-labels yaml-pull-request-labels
