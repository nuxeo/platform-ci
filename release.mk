tag:
	jx step tag --batch-mode --version=$(VERSION)

changelog:
	jx step changelog --batch-mode --version=v$(VERSION)

updatebot:
	@:

release: tag changelog updatebot
	@:

.PHONY: changelog updatebot release
