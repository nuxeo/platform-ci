include boot.mk

.tmp:
	@mkdir .tmp

clean: boot~clean
	rm -fr .tmp

system/helmfile.yaml apps/helmfile-augmented.yaml: jx-apps.yaml jx-requirements.yaml apps/helmfile-augment.yaml | .tmp
	jx step create helmfile
	awk '(FNR==1) { print "---" }1' apps/helmfile.yaml apps/helmfile-augment.yaml | \
          yq r -d'*' -j -P - | jq --slurp add - | yq r -P - > apps/helmfile-augmented.yaml

helmfile.yaml: system/helmfile.yaml apps/helmfile-augmented.yaml; @touch helmfile.yaml

ifdef google-client-secret
export jenkins_operator_secrets_master_template =
define jenkins_operator_secrets_master_template =
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-operator-secrets-master
data:
  SECURITY_OAUTH2_CLIENT_ID: $(shell jq .web.client_id $(google-client-secret) | tr -d '"' | base64 --wrap=0)
  SECURITY_OAUTH2_CLIENT_SECRET: $(shell jq .web.client_secret $(google-client-secret) | tr -d '"' | base64 --wrap=0)
endef

export jenkins_operator_casc_master_enabled =
define jenkins_operator_casc_master_enabled =
master:
  casc:
    enabled: true
endef

apps/jenkins-servers/jenkins-operator-master-casc-enabled.yaml:
	echo "$${jenkins_operator_secrets_master_template}"  | kubectl apply -f -
	echo "$${jenkins_operator_casc_master_enabled}" > $(@)
	git commit -m 'enabled jenkins master casc configuration' $(@)
	git push
endif

%~template:
	helmfile --selector name=$(*) template

%~diff:
	helmfile --selector name=$(*) diff

%~sync:
	helmfile --selector name=$(*) sync

%~destroy:
	helmfile --selector name=$(*) destroy
