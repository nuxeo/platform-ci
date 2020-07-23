workspace-pvc-name ?= $(shell echo $(JOB_NAME) | tr '[:upper:]' '[:lower:]' | tr / -)

export workspace_pvc_template
define workspace_pvc_template
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: $(workspace-pvc-name)
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 20Gi
    storageClassName: standard
endef

workspace-pvc:
  echo "$${workspace_pvc_template}" | kubectl apply --namespace=$(JX_NAMESPACE) -f -

workspace-pvc!delete:
workspace-pvc!delete:
  $(if $(JX_PR_LABELS_KEEP_WORKSPACE), :, kubectl delete --namespace=$(JX_NAMESPACE) pvc/$(workspace-pvc-name) --wait=false)
