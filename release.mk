tag:
	jx step tag --version $(VERSION)

changelog:
	jx step changelog --version  v$(VERSION)

updatebot:
	@:

release: tag changelog updatebot

.PHONY: tag changelog updatebot release
