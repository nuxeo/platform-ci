%~image: skaffold.yaml
	skaffold build -f skaffold.yaml -b $*

.PHONY: %~image
