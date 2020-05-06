this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

include $(this-dir)/macros.mk
include $(this-dir)/env.mk

help: ## targets help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z~_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: help

# git setup

git-credentials:
	jx step git credentials
	git config credential.helper store

git-fetch-tags: git-credentials
	git fetch --tags --quiet

.PHONY: git-credentials git-fetch-tags

# pipeline stage target

workspace: git-credentials git-fetch-tags workspace.d
	@:

workspace.d:
	@

.PHONY: workspace workspace.d

# misc

/usr/bin/strace:
	yum install --assumeyes strace
