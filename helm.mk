NAME=$(notdir $(realpath $(dir $(firstword $(MAKEFILE_LIST)))))

export chart_template

Chart.yaml:
	@echo "$${chart_template}" > Chart.yaml

.PHONY: Chart.yaml

export requirements_template

requirements.yaml:
	@echo "$$requirements_template" > requirements.yaml

.PHONY: requirements.yaml

export values_template

values.yaml:
	@echo "$$values_template" > values.yaml

.PHONY: values.yaml

define values-files ?=
$(wildcard values*.yaml)
endef

define values-options =
$(foreach file,$(values-files),--values $(file))
endef

values: values.yaml
	@:

# helm setup

export HELM_HOME ?= $(top-dir)/.helm

helm-setup: 
	helm init --client-only
	helm repo list | grep -q 'local.*http://127.0.0.1:8879/charts' && helm repo remove local || true
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm repo add storage.googleapis.com  https://storage.googleapis.com/chartmuseum.jenkins-x.io
	helm repo add jenkins-x-chartmuseum   http://jenkins-x-chartmuseum:8080
	helm repo update

workspace: helm-setup

.PHONY: helm-setup

helm~template: Chart.yaml requirements.yaml values
	helm template --name nos $(values-options) .

helm~build: Chart.yaml requirements.yaml values
	jx --verbose step helm build

helm~install: Chart.yaml requirements.yaml values
	jx --verbose step helm install --name $(NAME) --namespace $(JX_NAMESPACE) .

helm~release: Chart.yaml requirements.yaml values
	jx --verbose step helm release

helm~delete: 
	jx --verbose step helm delete $(NAME) --namespace $(JX_NAMESPACE)

.PHONY: helm~template helm~build helm~install helm~release helm~delete 
