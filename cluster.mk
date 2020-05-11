.tmp:
	@mkdir .tmp

include boot-requirements.mk
include boot-secrets.mk
include boot-git-url.mk

this-git-owner := $(git-owner)
this-cluster-name = jxlabs-nos-$(this-git-owner)

cluster~%: git-owner = $(lastword $(subst @, ,$(@)))
cluster~%: cluster-name = jxlabs-nos-$(git-owner)
cluster~%: git-url = https://github.com/$(git-owner)/$(dev-repository)
cluster~%: vault-sa = $(cluster-name)-vt
cluster~%: dev-ingress-domain = $(cluster-name).build-jx-prod.build.nuxeo.com
cluster~%: boot-config-url := $(shell git config  remote.origin.url)

cluster~boot@%: cluster~update@% cluster~boot-create@% cluster~boot-run@% ; @:

export GITHUB_TOKEN

cluster~boot-create@%: GITHUB_TOKEN=$(git-token)
cluster~boot-create@%: | .tmp
	@rm -fr .tmp/$(dev-repository)
	@- hub delete --yes $(git-owner)/$(dev-repository) 2>/dev/null && sleep 5
	hub fork --org $(git-owner)
	git remote remove $(git-owner) 2>/dev/null
	cd .tmp && git clone https://github.com/$(git-owner)/$(dev-repository)
	jx --dir=.tmp/$(dev-repository) edit requirements \
	  --provider=gke \
	  --project=$(gcp-project) --cluster=$(cluster-name) --zone=$(gcp-zone) --region=$(gcp-region) \
	  --boot-config-url=$(boot-config-url) \
	  --env-git-owner=$(git-owner) \
	  --domain=$(dev-ingress-domain) \
	  --registry=gcr.io/$(cluster-name) \
	  --vault-sa=$(vault-sa)
	(cd  .tmp/$(dev-repository); \
	 git commit -m 'forked $(boot-config-url) and re-configured for $(cluster-name)' jx-requirements.yml; \
         git push origin master)
	rm -fr .tmp/$(dev-repository)

export KUBECONFIG

cluster~boot-run@%: KUBECONFIG=.tmp/kubeconfig~$(*)
cluster~boot-run@%:
	gcloud config set compute/region $(gcp-region)
	gcloud config set compute/zone $(gcp-zone)
	gcloud config set core/project $(gcp-project)
	gcloud container clusters get-credentials $(cluster-name)
	kubectl config use-context gke_$(gcp-project)_$(gcp-zone)_$(cluster-name)
	helm repo add jxlabs-nos gs://jxlabs-nos-charts
	JX_LOG_LEVEL=debug jxl boot run --batch-mode \
	  --chart=jxlabs-nos/jxl-boot \
	  --git-url=$(git-url) --git-user=$(git-user) --git-token=$(git-token) \
          --job

cluster~update@%: 
	make -C infra update@$(*)

cluster~diff@%: 
	make -C infra diff@$(*)

cluster~preview@%: 
	make -C infra preview@$(*)

cluster~destroy@%:
	make -C infra destroy@$(*)

cluster~clean@%: clean
	make -C infra clean@$(*)
