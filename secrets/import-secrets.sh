#!/bin/bash
set -e

for secret in $(cat $1)
do
  kubectl get secret $secret --namespace=$2 -o yaml | \
    sed "s|namespace: $2|namespace: $NAMESPACE|g" | \
    kubectl apply --namespace=$NAMESPACE -f -
done
