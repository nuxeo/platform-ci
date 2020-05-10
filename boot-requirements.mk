.tmp/boot-requirements.yaml: | .tmp
	@kubectl get environments/dev -o jsonpath='{.spec.teamSettings.bootRequirements}' > $(@)

export boot_requirements_cluster_awk_template :=
define boot_requirements_cluster_awk_template
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "cluster.clusterName" { printf "export cluster-name := %s\n", trim($$2) }
$$1 == "cluster.project" { printf "export gcp-project := %s\n", trim($$2) }
$$1 == "cluster.region" { printf "export gcp-region := %s\n", trim($$2) }
$$1 == "cluster.zone" { printf "export gcp-zone := %s\n", trim($$2) }
$$1 == "cluster.environmentGitOwner" { printf "export git-owner := %s\n", trim($$2) }
endef

.tmp/boot-requirements-cluster.awk: | .tmp
	@echo "$${boot_requirements_cluster_awk_template}" > $(@)

export boot_requirements_environment_dev_awk_template :=
define boot_requirements_environment_dev_awk_template
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 ~ /repository/ { printf "export dev-repository := %s\n", trim($$2) }
$$1 ~ /ingress.tls.email/ { printf "export dev-ingress-tls-email := %s\n", trim($$2) }
$$1 ~ /ingress.domain/ { printf "export dev-ingress-domain := %s\n", trim($$2) }
endef

.tmp/boot-requirements-dev-environment.awk: | .tmp
	@echo "$${boot_requirements_environment_dev_awk_template}" > $(@)

.tmp/boot-requirements.mk: .tmp/boot-requirements.yaml
.tmp/boot-requirements.mk: .tmp/boot-requirements-cluster.awk
.tmp/boot-requirements.mk: .tmp/boot-requirements-dev-environment.awk
.tmp/boot-requirements.mk:
		@( yq r .tmp/boot-requirements.yaml --printMode pv 'cluster.*' | awk -f .tmp/boot-requirements-cluster.awk; \
	           yq r .tmp/boot-requirements.yaml --printMode pv "environments.(key==dev).**" | awk -f .tmp/boot-requirements-dev-environment.awk) > $(@)

-include .tmp/boot-requirements.mk

