this-mk:=$(lastword $(MAKEFILE_LIST))
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

define shell-assign =
$(eval $(1) := $$(shell $2))$($(1))
endef

export BRANCH_NAME ?= $(call shell-assign, BRANCH_NAME, git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
export BUILD_NUMBER ?= 0

export ORG ?= nuxeo
export TEAM ?= nos
export JX_NAMESPACE ?= $(TEAM)
export DOCKER_REGISTRY ?= localhost:5000
export DOCKER_NAMESPACE ?= $(ORG)/$(TEAM)/jenkins-x

export RELEASE_VERSION := $(shell git rev-parse HEAD > /dev/null 2>&1 && jx-release-version -folder $(top-dir))

ifneq ($(BRANCH_NAME), master)
export VERSION ?= $(RELEASE_VERSION)-$(BRANCH_NAME)-$(BUILD_NUMBER)
else
export VERSION ?= $(RELEASE_VERSION)
endif

export SCM_REPO := $(shell git remote get-url origin)
export SCM_REF := $(shell git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)

export CHART_REPOSITORY ?= http://jenkins-x-chartmuseum:8080

