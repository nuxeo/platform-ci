include ../make.d/env.mk
include ../make.d/pulumi.mk

init-post.d@%: config@% 

config@%: githubConfig@% bootSecrets@% ; @:

githubConfig@%:
	@:$(call check-variable-defined,git-owner git-repo)
	pulumi config set --plaintext --path githubConfig.owner $(git-owner)
	pulumi config set --plaintext --path githubConfig.repo $(git-repo)

bootSecrets@%:
	@:$(call check-variable-defined,admin-username admin-password hmac-token git-username git-email git-token)
	pulumi config set --plaintext --path bootSecrets.adminUser.username $(admin-username)
	pulumi config set --plaintext --secret --path bootSecrets.adminUser.password $(admin-password)
	pulumi config set --secret --path bootSecrets.hmacToken $(hmac-token)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.username $(git-username)
	pulumi config set --plaintext --path bootSecrets.pipelineUser.email $(git-email)
	pulumi config set --secret --path bootSecrets.pipelineUser.token $(git-token)
