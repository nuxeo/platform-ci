top-dir=$(realpath $(dir $(lastword $(MAKEFILE_LIST)))/..)

define check-variable-defined =
    $(strip $(foreach 1,$1,
        $(call __check-variable-defined,$1,$(strip $(value 2)))))
endef

define __check-variable-defined =
    $(if $(value $1),,
        $(error Undefined variable '$1'$(if $2, ($2))$(if $(value @),
                required by target '$@')))
endef

export BRANCH_NAME ?= $(strip $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown))
export BUILD_NUMBER ?= latest

export ORG ?= nuxeo
export TEAM ?= nos
export JX_NAMESPACE ?= $(TEAM)
export DOCKER_REGISTRY ?= localhost:5000
export DOCKER_NAMESPACE ?= $(ORG)/$(TEAM)/jenkins-x

export RELEASE_VERSION ?= $(shell git rev-parse HEAD > /dev/null 2>&1 && jx-release-version -folder $(top-dir)/.. 2>/dev/null || echo 0.0.0)
ifneq ($(BRANCH_NAME), master)
export VERSION ?= $(RELEASE_VERSION)-$(BRANCH_NAME)-$(BUILD_NUMBER)
else
export VERSION ?= $(RELEASE_VERSION)
endif

export SCM_REPO ?= $(shell git remote get-url origin)
export SCM_REF ?= $(shell git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)

export CHART_REPOSITORY ?= http://jenkins-x-chartmuseum:8080

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
