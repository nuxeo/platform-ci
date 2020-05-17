ifndef npm-mk

npm-mk := $(lastword $(MAKEFILE_LIST))

npm-prefix := $(shell npm config get prefix)

$(npm-prefix)/bin/pnpm:
	sudo npm install -g pnpm

/usr/bin/expect:
	sudo yum install --assumeyes expect

export npm_adduser_template
define npm_adduser_template =
spawn npm adduser
expect {
  "Username:" {send "$(user)\r"; exp_continue}
  "Password:" {send "$(pass)\r"; exp_continue}
  "Email: (this IS public)" {send "$(email)\r"; exp_continue}
}
endef

node-modules: .npmrc pnpm-workspace.yaml
	pnpm recursive install 

npm-adduser: pass=$(shell kubectl get secrets/nexus -o jsonpath='{.data.password}' | base64 -d)
npm-adduser: user=admin
npm-adduser: email=nos+jx-bot@nuxeo.com
npm-adduser: /usr/bin/expect
	echo "$$npm_adduser_template" | expect

npm-setcache:
	npm set cache

npm-bower: | /usr/bin/pnpm
	sudo pnpm install -g bower
	echo '{ "allow_root": true }' > ~/.bowerrc

npm-grunt: | /usr/bin/pnpm
	sudo pnpm install -g grunt

npm-setup: npm-adduser npm-setcache npm-bower npm-grunt | /usr/bin/pnpm
	@:

npm-install: node-modules; @:

npm-clean:
	rm -fr nodes_modules _cacache _locks _logs anonymous-cli-metrics.json bin

workspace.d: npm-setup

endif
