#!/bin/sh

tempfile=helmfile-$$.yaml

awk '(FNR==1) { print "---" }1' helmfile.yaml helmfile-augment.yaml | yq r -d'*' -j -P - | jq --slurp add - | yq r -P - > $tempfile && mv -f $tempfile helmfile.yaml
