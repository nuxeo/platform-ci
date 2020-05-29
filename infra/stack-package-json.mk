export stack_package_json
define stack_package_json =
{
    "name": "jxlabs-nos-infra-$(name)",
    "main": "index.js",
    "dependencies": {
        "@google-cloud/kms": "^2.0.0",
        "@pulumi/gcp": "^3.3.0",
        "@pulumi/pulumi": "^2.1.0",
        "@pulumi/kubernetes": "^2.0.0",
        "@pulumi/github": "^1.1.0",
        "@types/node": "^13.13.5",
        "yaml": "1.10.0"
    },
    "devDependencies": {
        "lint": "^0.7.0"
    }
}
endef

.PRECIOUS: package.json

package.json: name:=main
package.json:
	echo "$${stack_package_json}" > $(@)

install: package.json
	npm install

%/package.json: name:=$(*)
%/package.json:
	echo "$${stack_package_json}" > $(@)

packages: ; @:
