.tmp:
	@mkdir .tmp


include boot-requirements.mk
include boot-secrets.mk
include boot-git-url.mk

submodules:
	git submodule update --init --recursive

init: | submodules ; @:

cluster~%: git-owner = $(lastword $(subst @, ,$(@)))
cluster~%: cluster-name = jxlabs-nos-$(git-owner)
cluster~%: git-url = https://github.com/$(git-owner)/$(dev-repository)
cluster~%: vault-sa = $(cluster-name)-vt
cluster~%: dev-ingress-domain = $(cluster-name).build-jx-prod.build.nuxeo.com
cluster~%: boot-config-url = $(shell git config  remote.origin.url)
cluster~%: initial-config-url = $(shell git config remote.origin.url)

cluster~boot@%: cluster~update@% cluster~boot-create@% cluster~boot-run@% ; @:

/usr/local/bin/hub:
	$(error I need you to install hub from github -- https://hub.github.com/)

cluster~select@%:
	kubectl config use-context gke_$(gcp-project)_$(gcp-zone)_$(cluster-name)

cluster~boot-clean@%: | /usr/local/bin/hub
	rm -fr .tmp/$(dev-repository)
	-hub delete --yes $(git-owner)/$(dev-repository)

cluster~boot-create@%: cluster~boot-clean@% 
	JX_LOG_LEVEL=debug jxl boot create --batch-mode \
	  --dir=.tmp/$(dev-repository) \
          --provider=gke \
	  --project=$(gcp-project) --cluster=$(cluster-name) --zone=$(gcp-zone) --region=$(gcp-region) \
	  --initial-git-url=$(initial-config-url) --boot-config-url=$(boot-config-url) \
	  --env-git-owner=$(git-owner) \
          --domain=$(dev-ingress-domain) \
	  --registry=gcr.io/$(cluster-name) \
          --vault-sa=$(vault-sa)

cluster~boot-run@%: cluster~select@%
	helm repo add jxlabs-nos-jxl https://nxmatic.github.io/jxlabs-nos-jxl/charts/jxl-boot
	JX_LOG_LEVEL=debug jxl boot run --batch-mode \
          --chart=jxlabs-nos-jxl/jxl-boot \
	  --git-url=$(git-url) --git-user=$(git-user) --git-token=$(git-token) 

cluster~clean: clean
	make -C infra cluster~clean

cluster~update@%: | submodules
	make -C infra cluster~update@$(*)

cluster~diff@%: | submodules
	make -C infra cluster~diff@$(*)

cluster~preview@%: | submodules
	make -C infra cluster~preview@$(*)

cluster~destroy@%: init
	make -C infra cluster~destroy@$(*)
