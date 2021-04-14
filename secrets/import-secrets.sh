#!/bin/bash
set -e

for secret in $(cat $1)
do
  kubectl get secret $secret --namespace=$2 --export -o yaml |\
    kubectl apply --namespace=$NAMESPACE -f -
done
