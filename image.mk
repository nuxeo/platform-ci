%~image: skaffold.yaml %~image.d
	skaffold build -f skaffold.yaml -b $*

%~image.d:
	@:

.PHONY: %~image %~image.d
