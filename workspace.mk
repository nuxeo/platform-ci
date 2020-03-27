top-dir=$(realpath $(dir $(lastword $(MAKEFILE_LIST)))/..)

export BRANCH_NAME ?= $(strip $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown))
export BUILD_NUMBER ?= latest

export ORG ?= nuxeo
export TEAM ?= nos
export JX_NAMESPACE ?= $(TEAM)
export DOCKER_REGISTRY ?= localhost:5000
export DOCKER_NAMESPACE ?= $(ORG)/$(TEAM)/jenkins-x

export RELEASE_VERSION ?= $(shell git rev-parse HEAD > /dev/null 2>&1 && jx-release-version -folder $(top-dir)/.. 2>/dev/null || echo 0.0.0)
export VERSION ?= $(RELEASE_VERSION)-$(BRANCH_NAME)-$(BUILD_NUMBER)

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

# helm setup

export HELM_HOME ?= $(HOME)/.helm

helm-setup:
	rm -fr $(HELM_HOME) && mkdir -p $(HELM_HOME)
	helm init --client-only
	helm repo list | grep -q 'local.*http://127.0.0.1:8879/charts' && helm repo remove local || true
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm repo add storage.googleapis.com  https://storage.googleapis.com/chartmuseum.jenkins-x.io
	helm repo add jenkins-x-chartmuseum   http://jenkins-x-chartmuseum:8080
	helm repo update --debug

.PHONY: helm-setup

# pipeline stage target

workspace: git-credentials git-fetch-tags helm-setup workspace.d
	@:

workspace.d:
	@

.PHONY: workspace workspace.d
