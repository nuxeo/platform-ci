export BRANCH_NAME ?= $(strip $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown))
export BUILD_NUMBER ?= latest

export ORG ?= nuxeo
export TEAM ?= nos
export JX_NAMESPACE ?= $(TEAM)
export DOCKER_REGISTRY ?= localhost:5000
export DOCKER_NAMESPACE ?= $(ORG)/$(TEAM)/jenkins-x

export RELEASE_VERSION ?= $(shell jx-release-version 2>/dev/null || echo 0.0.0)
export VERSION ?= $(RELEASE_VERSION)-$(BRANCH_NAME)-$(BUILD_NUMBER)

export SCM_REPO ?= $(shell git remote get-url origin)
export SCM_REF ?= $(shell git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)


# git setup

git-credentials:
	jx step git credentials
	git config credential.helper store

.PHONY: git-credentials

git-fetch-tags: git-credentials
	git fetch --tags --quiet

.PHONY: git-fetch-tags

# helm setup

helm-setup:
	helm init --client-only
	helm repo remove local
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io

.PHONY: helm-setup

# pipeline stage target

workspace: git-credentials git-fetch-tags helm-setup
	@:
