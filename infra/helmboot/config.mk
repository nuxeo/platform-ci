pulumi~stack-config: github-config
pulumi~stack-config: boot-secrets-config

github-config:
	@:$(call check-variable-defined,git-owner dev-repository)
	pulumi config set --plaintext --path githubConfig.owner $(git-owner)
	pulumi config set --plaintext --path githubConfig.repo $(dev-repository)

define boot_secret_config_shell_script_auth =
	pulumi config set --plaintext --path 'bootSecrets.$(1).auth[$($(1)-auth-$(2)-index)].name' $(2)
	pulumi config set --plaintext --path 'bootSecrets.$(1).auth[$($(1)-auth-$(2)-index)].url' $($(1)-auth-$(2)-url)
	pulumi config set --plaintext --path 'bootSecrets.$(1).auth[$($(1)-auth-$(2)-index)].username' $($(1)-auth-$(2)-username)
	echo "$${$(1)_auth_$(subst -,_,$(2))_password}" | pulumi config set --secret --path 'bootSecrets.$(1).auth[$($(1)-auth-$(2)-index)].password'

endef

export boot_secret_config_shell_script_template
define boot_secret_config_shell_script_template :=
	pulumi config set --secret --path github:token $(git-token)
	pulumi config set --plaintext --path bootSecrets.adminUser.username $(admin-username)
	pulumi config set --secret --path bootSecrets.adminUser.password $(admin-password)
	pulumi config set --secret --path bootSecrets.hmacToken $(hmac-token)
	pulumi config set --secret --path bootSecrets.pulumiToken $(pulumi-token)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.username $(git-username)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.email $(git-email)
	pulumi config set --secret --path bootSecrets.pipelineUser.token $(git-token)
	pulumi config set --plaintext --path bootSecrets.oauth.clientId $(oauth-clientId)
	pulumi config set --secret --path bootSecrets.oauth.secret $(oauth-secret)
	echo "$${maven_settings}" | pulumi config set --secret --path bootSecrets.mavenSettings
	pulumi config set --secret --path bootSecrets.jira.username $(jira-username)
	pulumi config set --secret --path bootSecrets.jira.password $(jira-password)
	pulumi config set --secret --path bootSecrets.nexus.license $(nexus-license)
	echo "$${nexus_password}" | pulumi config set --secret --path bootSecrets.nexus.passwords 
$(foreach tool,docker nodejs,$(foreach index,$($(tool)-auth-indexes),$(call boot_secret_config_shell_script_auth,$(tool),$(index))))
endef

pfouh:
	echo "$${boot_secret_config_shell_script_template}"


boot-secrets-config:
	$(call check-variable-defined,admin-username admin-password hmac-token pulumi-token git-username git-email git-token oauth-clientId oauth-secret)	
	echo "$${boot_secret_config_shell_script_template}" | sh -ex
