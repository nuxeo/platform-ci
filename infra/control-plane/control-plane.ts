import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config"

import { StackReference } from "@pulumi/pulumi";

let masterVersionOr = () =>
    _.options.masterVersion || pulumi.output(gcp.container.getEngineVersions()).
        latestMasterVersion.apply(v => `${v}`);


export const cluster = new gcp.container.Cluster("cluster", {
    name: `jxlabs-nos-${_.env}`,
    description: "jxlabs nos cluster",
    minMasterVersion: _.options.masterVersion,
    enableKubernetesAlpha: _.options.enableKubernetesAlpha,
    enableLegacyAbac: _.options.enableLegacyAbac,
    initialNodeCount: 1,
    removeDefaultNodePool: true,
    location: gcp.config.zone,
    resourceLabels: {
        "created-by": _.createdBy,
        "created-with": "pulumi",
    }
});

export const nodePool = new gcp.container.NodePool("default", {
    autoscaling: {
        maxNodeCount: _.options.nodePool.maxNodeCount,
        minNodeCount: _.options.nodePool.minNodeCount,
    },
    cluster: cluster.name,
    location: cluster.location,
    management: {
        autoRepair: _.options.nodePool.autoRepair,
        autoUpgrade: _.options.nodePool.autoUpgrade,
    },
    name: "default-pool",
    nodeConfig: {
        diskSizeGb: _.options.nodePool.nodeDiskSize,
        imageType: _.options.nodePool.imageType,
        machineType: _.options.nodePool.machineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: _.options.nodePool.nodePreemptible,
    },
    nodeCount: _.options.nodePool.minNodeCount,
});

export const k8sConfig = pulumi.
    all([cluster.name, cluster.endpoint, cluster.masterAuth]).
    apply(([name, endpoint, auth]) => {
        const context = `${gcp.config.project}_${gcp.config.zone}_${name}`;
        return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${auth.clusterCaCertificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
`;
    });