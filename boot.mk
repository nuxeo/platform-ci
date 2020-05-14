include infra/make.d/macros.mk

$(call check-variable-defined,boot-stack)

include boot-requirements.mk
include boot-secrets.mk
include boot-git-url.mk

this-cluster-name := $(cluster-name)
this-dev-repository := $(dev-repository)
this-dev-ingress-domain := $(dev-ingress-domain)

boot~%: cluster-name = jxlabs-nos-$(boot-stack)
boot~%: dev-repository = jxlabs-nos-helmboot-config-$(boot-stack)
boot~%: vault-sa = $(cluster-name)-vt
boot~%: dev-ingress-domain = $(cluster-name).build-jx-prod.build.nuxeo.com
boot~%: boot-config-url = https://github.com/$(git-owner)/$(dev-repository)

boot: boot~update boot~create boot~run ; @:

noop: ; @:

export GITHUB_TOKEN

export cluster_boot_create_script
define cluster_boot_create_script =
	hub delete --yes $(git-owner)/$(dev-repository) && sleep 2 || true
	hub create $(git-owner)/$(dev-repository) --remote-name $(name); 
	git checkout -b $(name)
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
	git push $(name) pfouh:master
	git checkout master
	git branch -D $(name)
	git remote remove $(name)
endef

boot~create: GITHUB_TOKEN:=$(git-token)
boot~create: tmpdir:=$(shell mktemp -d)
boot~create: 
	echo "$${cluster_boot_create_script}" | sh -x

export KUBECONFIG

boot~run: KUBECONFIG=.tmp/kubeconfig~$(boot-stack)
boot~run:
	gcloud config set compute/region $(gcp-region)
	gcloud config set compute/zone $(gcp-zone)
	gcloud config set core/project $(gcp-project)
	gcloud container clusters get-credentials $(cluster-name)
	kubectl config use-context gke_$(gcp-project)_$(gcp-zone)_$(cluster-name)
	helm repo add jxlabs-nos gs://jxlabs-nos-charts
	JX_LOG_LEVEL=debug jxl boot run --batch-mode \
	  --chart=jxlabs-nos/jxl-boot \
	  --git-url=$(boot-config-url) --git-ref=master --git-user=$(git-user) --git-token=$(git-token) \
          --job

boot~%:
	make -C infra infra-stack=$(boot-stack) infra~$(*)
