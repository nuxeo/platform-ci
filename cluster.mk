.tmp:
	@mkdir .tmp

include infra/make.d/macros.mk

$(call check-variable-defined,cluster-stack)

include boot-requirements.mk
include boot-secrets.mk
include boot-git-url.mk

boot~run: cluster~boot-run; @:
boot~create: cluster~boot-create; @:
boot~destroy: cluster~destroy; @:

this-cluster-name := $(cluster-name)
this-dev-repository := $(dev-repository)
this-dev-ingress-domain := $(dev-ingress-domain)

cluster~%: cluster-name = jxlabs-nos-$(cluster-stack)
cluster~%: dev-repository = $(this-dev-repository)-$(cluster-name)
cluster~%: vault-sa = $(cluster-name)-vt
cluster~%: dev-ingress-domain = $(cluster-name).build-jx-prod.build.nuxeo.com
cluster~%: boot-config-url = https://github.com/$(git-owner)/$(dev-repository)

cluster~boot: cluster~update cluster~boot-create cluster~boot-run ; @:

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

cluster~boot-create: GITHUB_TOKEN:=$(git-token)
cluster~boot-create: tmpdir:=$(shell mktemp -d)
cluster~boot-create: 
	echo "$${cluster_boot_create_script}" | sh -x

export KUBECONFIG

cluster~boot-run: KUBECONFIG=.tmp/kubeconfig~$(cluster-stack)
cluster~boot-run:
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

cluster~%:
	make -C infra infra-stack=$(cluster-stack) infra~$(*)
