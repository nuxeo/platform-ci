export JX_SECRETS_YAML ?= $(realpath .tmp/boot-secrets.yaml)

.tmp/boot-secrets.yaml: | .tmp
	@kubectl get secrets/jx-boot-secrets -o jsonpath='{.data.secrets\.yaml}' | base64 -d > $(@)

export boot_secrets_admin_user_awk_template :=
define boot_secrets_admin_user_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.adminUser.username" { print "export admin-username :=", trim($$2) }
$$1 == "secrets.adminUser.password" { print "export admin-password :=", trim($$2) }
endef

.tmp/boot-secrets-admin-user.awk: | .tmp
	@echo "$${boot_secrets_admin_user_awk_template}" > $(@)

export boot_secrets_pipeline_user_awk_template :=
define boot_secrets_pipeline_user_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.pipelineUser.email" { print "export git-email :=", trim($$2) }
$$1 == "secrets.pipelineUser.username" { print "export git-user :=", trim($$2) }
$$1 == "secrets.pipelineUser.token" { print "export git-token :=", trim($$2) }
endef

.tmp/boot-secrets-pipeline-user.awk: | .tmp
	@echo "$${boot_secrets_pipeline_user_awk_template}" > $(@)

export boot_secrets_hmac_token_awk_template :=
define boot_secrets_hmac_token_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.hmacToken" { print "export hmac-token :=", trim($$2) }
endef

.tmp/boot-secrets-hmac-token.awk: | .tmp
	@echo "$${boot_secrets_hmac_token_awk_template}" > $(@)

export boot_secrets_pulumi_token_awk_template :=
define boot_secrets_pulumi_token_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.pulumiToken" { print "export pulumi-token :=", trim($$2) }
endef

.tmp/boot-secrets-pulumi-token.awk: | .tmp
	@echo "$${boot_secrets_pulumi_token_awk_template}" > $(@)

export boot_secrets_oauth_awk_template :=
define boot_secrets_oauth_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.oauth.clientId" { print "export oauth-client-id :=", trim($$2) }
$$1 == "secrets.oauth.secret" { print "export oauth-secret :=", trim($$2) }
endef

.tmp/boot-secrets-oauth.awk: | .tmp
	@echo "$${boot_secrets_oauth_awk_template}" > $(@)

.PHONY: .tmp/boot-secrets.mk
.PRECIOUS: .tmp/boot-secrets.mk

export boot_secrets_shell_script_template 
define boot_secrets_shell_script_template :=
set -ex
yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.adminUser.*' | awk -f .tmp/boot-secrets-admin-user.awk
yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.pipelineUser.*' | awk -f .tmp/boot-secrets-pipeline-user.awk
yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.hmacToken' | awk -f .tmp/boot-secrets-hmac-token.awk
yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.pulumiToken' | awk -f .tmp/boot-secrets-pulumi-token.awk
yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.oauth.*' | awk -f .tmp/boot-secrets-oauth.awk
endef

.tmp/boot-secrets.mk: .tmp/boot-secrets.yaml
.tmp/boot-secrets.mk: .tmp/boot-secrets-admin-user.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-pipeline-user.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-hmac-token.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-pulumi-token.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-oauth.awk
.tmp/boot-secrets.mk:
	echo "$${boot_secrets_shell_script_template}" | sh  > $(@)

-include .tmp/boot-secrets.mk
