pulumi-stack-config: github-config
pulumi-stack-config: boot-secrets-config

github-config:
	@:$(call check-variable-defined,git-owner dev-repository)
	pulumi config set --plaintext --path githubConfig.owner $(git-owner)
	pulumi config set --plaintext --path githubConfig.repo $(dev-repository)

boot-secrets-config:
	@:$(call check-variable-defined,admin-username admin-password hmac-token pulumi-token git-user git-email git-token)
	pulumi config set --plaintext --path bootSecrets.adminUser.username $(admin-username)
	@pulumi config set --plaintext --secret --path bootSecrets.adminUser.password $(admin-password)
	@pulumi config set --secret --path bootSecrets.hmacToken $(hmac-token)
	@pulumi config set --secret --path bootSecrets.pulumiToken $(pulumi-token)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.username $(git-user)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.email $(git-email)
	@pulumi config set --secret --path bootSecrets.pipelineUser.token $(git-token)
	@pulumi config set --secret --path github:token $(git-token)
