.tmp/boot-requirements.yaml: | .tmp
	@kubectl get environments/dev -o jsonpath='{.spec.teamSettings.bootRequirements}' > $(@)

export boot_requirements_cluster_awk_template :=
define boot_requirements_cluster_awk_template
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "cluster.clusterName" { print "export cluster-name :=", trim($$2) }
$$1 == "cluster.project" { print "export gcp-project :=", trim($$2) }
$$1 == "cluster.region" { print "export gcp-region :=", trim($$2) }
$$1 == "cluster.zone" { print "export gcp-zone :=", trim($$2) }
$$1 == "cluster.environmentGitOwner" { print "export git-owner :=", trim($$2) }
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
$$1 ~ /repository/ { print "export dev-repository :=", trim($$2) }
$$1 ~ /ingress.tls.email/ { print "export dev-ingress-tls-email :=", trim($$2) }
$$1 ~ /ingress.domain/ { print "export dev-ingress-domain :=", trim($$2) }
endef

.tmp/boot-requirements-dev-environment.awk: | .tmp
	@echo "$${boot_requirements_environment_dev_awk_template}" > $(@)

.PHONY: .tmp/boot-requirements.mk
.PRECIOUS: .tmp/boot-requirements.mk

.tmp/boot-requirements.mk: .tmp/boot-requirements.yaml
.tmp/boot-requirements.mk: .tmp/boot-requirements-cluster.awk
.tmp/boot-requirements.mk: .tmp/boot-requirements-dev-environment.awk
.tmp/boot-requirements.mk:
		@( yq r .tmp/boot-requirements.yaml --printMode pv 'cluster.*' | awk -f .tmp/boot-requirements-cluster.awk; \
	           yq r .tmp/boot-requirements.yaml --printMode pv "environments.(key==dev).**" | awk -f .tmp/boot-requirements-dev-environment.awk) > $(@)

-include .tmp/boot-requirements.mk

