ifndef boot-mk

boot-mk := $(lastword $(MAKEFILE_LIST))

this-mk:=$(boot-mk)
this-dir:=$(realpath $(dir $(this-mk)))
top-dir:=$(realpath $(this-dir)/..)

include $(this-dir)/infra/make.d/macros.mk

include $(this-dir)/boot-requirements.mk
include $(this-dir)/boot-secrets.mk
include $(this-dir)/boot-git-url.mk


this-cluster-name := $(cluster-name)
this-boot-stack := $(lastword $(subst -, ,$(cluster-name)))
this-dev-repository := $(dev-repository)
this-dev-ingress-domain := $(dev-ingress-domain)
boot-stack ?= $(this-boot-stack)

boot~%: cluster-name = jxlabs-nos-$(boot-stack)
boot~%: dev-repository = jxlabs-nos-helmboot-config-$(boot-stack)
boot~%: vault-sa = $(cluster-name)-vt
boot~%: dev-ingress-domain = $(cluster-name).build-jx-prod.build.nuxeo.com
boot~%: boot-config-url = https://github.com/$(git-owner)/$(dev-repository)

boot: boot~update boot~create boot~run ; @:

boot~noop: ; @echo "we're operating from $(this-boot-stack) on-to the $(boot-stack) stack"

export GITHUB_TOKEN

export cluster_boot_create_script
define cluster_boot_create_script =
	git config url."https://github.com/".insteadOf git@github.com:
	hub delete --yes $(git-owner)/$(dev-repository) && sleep 2 || true
	hub create $(git-owner)/$(dev-repository) --remote-name $(cluster-name)
	git checkout -b $(cluster-name)
	jx edit requirements \
	   --provider=gke \
	   --project=$(gcp-project) --cluster=$(cluster-name) --zone=$(gcp-zone) --region=$(gcp-region) \
	   --boot-config-url=$(boot-config-url) \
	   --env-git-owner=$(git-owner) \
	   --domain=$(dev-ingress-domain) \
	   --registry=gcr.io/$(cluster-name) \
	   --vault-sa=$(vault-sa)
	sed -i s/$(this-dev-ingress-domain)/$(dev-ingress-domain)/ jx-requirements.yml 
	git commit -m 'forked $(boot-config-url) and re-configured for $(cluster-name)' jx-requirements.yml
	git push $(cluster-name) $(cluster-name):master
	git checkout master
	git branch -D $(cluster-name)
	git remote remove $(cluster-name)
endef

boot~create: GITHUB_TOKEN:=$(git-token)
boot~create: tmpdir:=$(shell mktemp -d)
boot~create: 
	echo "$${cluster_boot_create_script}" | sh -xe

kubeconfig:=$(abspath .tmp/kubeconfig~$(boot-stack))

$(kubeconfig):
	gcloud config set compute/region $(gcp-region)
	gcloud config set compute/zone $(gcp-zone)
	gcloud config set core/project $(gcp-project)
	gcloud container clusters get-credentials $(cluster-name)
	kubectl config use-context gke_$(gcp-project)_$(gcp-zone)_$(cluster-name)

boot~run: $(kubeconfig)
	helm repo add jxlabs-nos gs://jxlabs-nos-charts
	KUBECONFIG=$(kubeconfig) JX_LOG_LEVEL=debug jxl boot run --batch-mode \
	  --chart=jxlabs-nos/jxl-boot \
	  --git-url=$(boot-config-url) --git-ref=master --git-user=$(git-user) --git-token=$(git-token) \
          --job=false

boot~%:
	make -C infra infra-stack=$(boot-stack) $(*)

system/helmfile.yaml apps/helmfile.yaml: jx-apps.yml jx-requirements.yml | .tmp
	jx step create helmfile

boot~helmfile-%: helmfile.yaml $(KUBECONFIG)
	$(call check-variable-defined,name)
	helmfile --selector name=$(name) $(*)

endif
