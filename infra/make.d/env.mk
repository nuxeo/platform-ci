ifndef env-included-mk

env-mk := $(lastword $(MAKEFILE_LIST))

this-mk:=$(env-mk)
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

include $(this-dir)/macros.mk

export BRANCH_NAME ?= $(call shell-assign, BRANCH_NAME, git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)

export BUILD_NUMBER ?= 0

export ORG ?= nxmatic
export TEAM ?= nos
export JX_NAMESPACE ?= $(TEAM)
export DOCKER_REGISTRY ?= localhost:5000
export DOCKER_NAMESPACE ?= $(ORG)/$(TEAM)/jenkins-x

export RELEASE_VERSION := $(shell git rev-parse HEAD > /dev/null 2>&1 && jx-release-version -folder $(top-dir) 2>/dev/null|| echo 0.0.0)

ifneq ($(BRANCH_NAME), master)
export VERSION ?= $(RELEASE_VERSION)-$(BRANCH_NAME)-$(BUILD_NUMBER)
else
export VERSION ?= $(RELEASE_VERSION)
endif

export SCM_REPO := $(shell git remote get-url origin)
export SCM_REF := $(shell git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)

export CHART_REPOSITORY ?= http://jenkins-x-chartmuseum:8080

endif
