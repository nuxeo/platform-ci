npm-adduser: pass=$(shell kubectl get secrets/nexus -o jsonpath='{.data.password}' | base64 -d)
npm-adduser: user=admin
npm-adduser: email=nos+jx-bot@nuxeo.com
npm-adduser: /usr/bin/expect
	echo "$$npm_adduser_template" | expect

npm-setcache:
	npm set cache

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

npm-bower:
	sudo npm install -g bower
	echo '{ "allow_root": true }' > ~/.bowerrc

npm-grunt:
	sudo npm install -g grunt

npm-setup: npm-adduser npm-setcache npm-bower npm-grunt
	@:

npm-install:
	npm install -m --package-lock-only

workspace.d: npm-setup
