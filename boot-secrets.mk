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
jq -r '.secrets.hmacToken|"hmac-token := " + .' $(<)
jq -r '.secrets.pulumiToken|"pulumi-token := " + .' $(<)
jq -r '.secrets.docker.auth[]|"docker-auth-indexes += " + .name' $(<)
jq -r '.secrets.docker.auth|reduce range(0,length) as $$i (.; .[$$i].index = ($$i|tostring))|to_entries[]|"docker-auth-" + .value.name + "-index := " + (.key|tostring)' $(<)
jq -r  '.secrets.docker.auth[]|.name as $$name|to_entries[]|select(.key != "password" and .key != "name")|"docker-auth-"+$$name + "-" + .key + " := " + .value' $(<)
jq -r  '.secrets.docker.auth[]|(.name|split("-")|join("_")) as $$name|to_entries[]|select(.key == "password")| "export docker_auth_"+$$name+"_" + .key + "\\n" + "define docker_auth_"+$$name+"_" + .key + " := \\n" + .value + "\\nendef"' $(<)
endef

.tmp/boot-secrets.mk: .tmp/boot-secrets.json
.tmp/boot-secrets.mk:
	echo "$${boot_secrets_shell_script_template}" | sh  > $(@)
