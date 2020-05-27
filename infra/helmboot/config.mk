pulumi~stack-config: github-config
pulumi~stack-config: boot-secrets-config

github-config:
	@:$(call check-variable-defined,git-owner dev-repository)
	pulumi config set --plaintext --path githubConfig.owner $(git-owner)
	pulumi config set --plaintext --path githubConfig.repo $(dev-repository)

define boot_secret_config_shell_script_docker_auth =
	pulumi config set --plaintext --path 'bootSecrets.docker.auth[$(docker-auth-$(1)-index)].url' $(docker-auth-$(1)-url)
	pulumi config set --plaintext --path 'bootSecrets.docker.auth[$(docker-auth-$(1)-index)].username' $(docker-auth-$(1)-username)
	echo "$${docker_auth_$(subst -,_,$(1))_password}" | pulumi config set --secret --path 'bootSecrets.docker.auth[$(docker-auth-$(1)-index)].password'

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
$(foreach index,$(docker-auth-indexes),$(call boot_secret_config_shell_script_docker_auth,$(index)))
endef

pfouh:
	echo "$${boot_secret_config_shell_script_template}"


boot-secrets-config:
	$(call check-variable-defined,admin-username admin-password hmac-token pulumi-token git-username git-email git-token oauth-clientId oauth-secret)	
	echo "$${boot_secret_config_shell_script_template}" | sh 

