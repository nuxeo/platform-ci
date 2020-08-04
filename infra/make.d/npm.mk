npm-install: .npmrc pnpm-workspace.yaml package.json
	pnpm recursive install

npm-clean:
	rm -rf node_modules
