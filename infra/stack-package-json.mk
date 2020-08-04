export stack_package_json
define stack_package_json =
{
  "name": "$(cluster-prefix)-infra-$(name)",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/kms": "^2.0.0",
    "@pulumi/gcp": "^3.6.0",
    "@pulumi/github": "^1.3.0",
    "@pulumi/kubernetes": "^2.2.0",
    "@pulumi/pulumi": "^2.2.1",
    "@types/node": "^13.13.9",
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
	echo "$${stack_package_json}" > $@

%/package.json: name:=$*
%/package.json:
	echo "$${stack_package_json}" > $@

packages: ; @:
