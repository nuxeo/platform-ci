.tmp/boot-secrets.yaml: | .tmp
	@kubectl get secrets/jx-boot-secrets -o jsonpath='{.data.secrets\.yaml}' | base64 -d > $(@)

export boot_secrets_admin_user_awk_template :=
define boot_secrets_admin_user_awk_template :=
BEGIN { FS=":" }
function trim(field){
   gsub(/^ +| +$$/,"", field); 
   return field
}
$$1 == "secrets.adminUser.username" { printf "export admin-username := %s\n", trim($$2) }
$$1 == "secrets.adminUser.password" { printf "export admin-password := %s\n", trim($$2) }
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
$$1 == "secrets.pipelineUser.email" { printf "export git-email := %s\n", trim($$2) }
$$1 == "secrets.pipelineUser.username" { printf "export git-user := %s\n", trim($$2) }
$$1 == "secrets.pipelineUser.token" { printf "export git-token := %s\n", trim($$2) }
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
$$1 == "secrets.hmacToken" { printf "export hmac-token := %s\n", trim($$2) }
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
$$1 == "secrets.pulumiToken" { printf "export pulumi-token := %s\n", trim($$2) }
endef

.tmp/boot-secrets-pulumi-token.awk: | .tmp
	@echo "$${boot_secrets_pulumi_token_awk_template}" > $(@)

.tmp/boot-secrets.mk: .tmp/boot-secrets.yaml
.tmp/boot-secrets.mk: .tmp/boot-secrets-admin-user.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-pipeline-user.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-hmac-token.awk
.tmp/boot-secrets.mk: .tmp/boot-secrets-pulumi-token.awk
.tmp/boot-secrets.mk:
	@( yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.adminUser.*' | awk -f .tmp/boot-secrets-admin-user.awk; \
           yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.pipelineUser.*' | awk -f .tmp/boot-secrets-pipeline-user.awk; \
           yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.hmacToken' | awk -f .tmp/boot-secrets-hmac-token.awk; \
           yq r .tmp/boot-secrets.yaml --printMode pv 'secrets.pulumiToken' | awk -f .tmp/boot-secrets-pulumi-token.awk) > $(@)

-include .tmp/boot-secrets.mk
