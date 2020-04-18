import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config"

const cluster = new gcp.container.Cluster("cluster", {
    name: `jxlabs-nos-${_.env}`,
    description: "jxlabs nos cluster",
    minMasterVersion: _.masterVersion,
    enableKubernetesAlpha: _.enableKubernetesAlpha,
    enableLegacyAbac: _.enableLegacyAbac,
    initialNodeCount: _.minNodeCount,
    removeDefaultNodePool: true,
    location: gcp.config.zone,
    resourceLabels: {
        "created-by": _.createdBy,
        "created-with": "pulumi",
    }
});

const default_pool = new gcp.container.NodePool("default", {
    autoscaling: {
        maxNodeCount: _.maxNodeCount,
        minNodeCount: _.minNodeCount,
    },
    cluster: cluster.name,
    location: cluster.location,
    management: {
        autoRepair: _.autoRepair,
        autoUpgrade: _.autoUpgrade,
    },
    name: "default-pool",
    nodeConfig: {
        diskSizeGb: _.nodeDiskSize,
        imageType: _.imageType,
        machineType: _.nodeMachineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: _.nodePreemptible,
    },
    nodeCount: _.minNodeCount,
});


export const k8sConfig = pulumi.
    all([cluster.name, cluster.endpoint, cluster.masterAuth]).
    apply(([name, endpoint, auth]) => {
        const context = `${gcp.config.project}_${gcp.config.zone}_${cluster.name}`;
        return `apiVersion: v1
clusters:
- cluster:
certificate - authority - data: ${auth.clusterCaCertificate}
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
expiry - key: '{.credential.token_expiry}'
token - key: '{.credential.access_token}'
name: gcp
`;
    });

export const k8sProvider = new k8s.Provider("gkeK8s", {
    kubeconfig: k8sConfig,
});
