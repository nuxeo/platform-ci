install: 
	npm install -m --no-packages-lock

install@%: install; @:

login: PULUMI_TOKEN ?= $(cat /run/secrets/pulumi/token)
login:
	pulumi --non-interactive login

init@%: init-pre.d@% init-do@% init-post.d@%; @:

init-do@%: 
	test -n $$(pulumi stack ls -j 2>/dev/null | jq '.[] | select (.name == "$(*)") | .name') || pulumi --non-interactive stack init $(*)

init-post.d@%: tag.environment@% ; @:

init-pre.d@%: | install login
init-pre.d@%: ; @:

tag.environment@%:
	pulumi --non-interactive --stack=$(*) stack tag set environment $(*)

rm@%: 
	pulumi --non-interactive --stack=$(*) stack rm --yes 

select@%: 
	pulumi stack select $(*)

graph@%: 
	pulumi --non-interactive --stack=$(*) stack graph graph.dot

refresh@%: 
	pulumi --non-interactive --stack=$(*) refresh --yes --diff 

diff@%: Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) preview --diff 

update@%: init@% Pulumi.%.yaml
	pulumi --non-interactive --stack=$(*) update --yes 


destroy@%:
	pulumi --non-interactive --stack=$(*) destroy --yes 

Pulumi.%.yaml: stack-config; @:

stack-config: ; @:

stack-config: gcp-config

gcp-config:
	@:$(call check-variable-defined,gcp-project gcp-region gcp-zone)
	pulumi config set --plaintext --path gcp:project $(gcp-project)
	pulumi config set --plaintext --path gcp:region $(gcp-region)
	pulumi config set --plaintext --path gcp:zone $(gcp-zone)
