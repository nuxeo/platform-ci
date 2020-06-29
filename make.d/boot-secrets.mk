include .tmp/boot-secrets.mk

.PRECIOUS:.tmp/boot-secrets.yaml
.PRECIOUS:.tmp/boot-secrets.mk

.tmp/boot-secrets.yaml: | .tmp
	kubectl get secrets/jx-boot-secrets -o jsonpath='{.data.secrets\.yaml}' | base64 -d > $(@)

.SUFFIXES: .yaml .json

.yaml.json:
	yq r -j -P $(<) > $(@)

.PRECIOUS: .tmp/boot-secrets.mk

export boot_secrets_shell_script_template 
define boot_secrets_shell_script_template =
set -ex
jq -r '.secrets.adminUser|to_entries[]|"admin-" + .key + " := " + .value' $(<)
jq -r '.secrets.pipelineUser|to_entries[]|"git-" + .key + " := " + .value' $(<)
jq -r '.secrets.oauth|to_entries[]|"oauth-" + .key + " := " + .value' $(<)
jq -r '.secrets.nexus|to_entries[]|select(.key != "passwords")|"nexus-" + .key + " := " + .value' $(<)
jq -r '.secrets.nexus|to_entries[]|select(.key == "passwords")|"export nexus_" + .key + "\n" + "define nexus_" + .key + " := \n" + .value + "\nendef"' $(<)
jq -r '.secrets.hmacToken|"hmac-token := " + .' $(<)
jq -r '.secrets.pulumiToken|"pulumi-token := " + .' $(<)
jq -r '.secrets.docker.auth[]|"docker-auth-indexes += " + .name' $(<)
jq -r '.secrets.docker.auth|reduce range(0,length) as $$i (.; .[$$i].index = ($$i|tostring))|to_entries[]|"docker-auth-" + .value.name + "-index := " + (.key|tostring)' $(<)
jq -r '.secrets.docker.auth[]|.name as $$name|to_entries[]|select(.key != "password" and .key != "name")|"docker-auth-"+$$name + "-" + .key + " := " + .value' $(<)
jq -r '.secrets.docker.auth[]|(.name|split("-")|join("_")) as $$name|to_entries[]|select(.key == "password")| "export docker_auth_"+$$name+"_" + .key + "\n" + "define docker_auth_"+$$name+"_" + .key + " := \n" + .value + "\nendef"' $(<)
jq -r '.secrets.nodejs.auth[]|"nodejs-auth-indexes += " + .name' $(<)
jq -r '.secrets.nodejs.auth|reduce range(0,length) as $$i (.; .[$$i].index = ($$i|tostring))|to_entries[]|"nodejs-auth-" + .value.name + "-index := " + (.key|tostring)' $(<)
jq -r '.secrets.nodejs.auth|reduce range(0,length) as $$i (.; .[$$i].index = ($$i|tostring))|to_entries[]|"nodejs-auth-" + .value.name + "-index := " + (.key|tostring)' $(<)
jq -r '.secrets.nodejs.auth[]|.name as $$name|to_entries[]|select(.key != "password" and .key != "name")|"nodejs-auth-"+$$name + "-" + .key + " := " + .value' $(<)
jq -r '.secrets.nodejs.auth[]|(.name|split("-")|join("_")) as $$name|to_entries[]|select(.key == "password")| "export nodejs_auth_"+$$name+"_" + .key + "\n" + "define nodejs_auth_"+$$name+"_" + .key + " := \n" + .value + "\nendef"' $(<)
jq -r '.secrets.mavenSettings|"export maven_settings\ndefine maven_settings := \n" + . + "\nendef"' $(<)
jq -r '.secrets.jira|to_entries[]|"jira-" + .key + " := " + .value' $(<)
echo 'git-user := $$(git-username)'
endef

.tmp/boot-secrets.mk: .tmp/boot-secrets.json
.tmp/boot-secrets.mk:
	echo "$${boot_secrets_shell_script_template}" | sh  > $(@)
