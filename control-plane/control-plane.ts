import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config"

const cluster = new gcp.container.Cluster("cluster", {
    description: "jxlabs nos cluster",
    minMasterVersion: _.masterVersion,
    enableKubernetesAlpha: (_.enableKubernetesAlpha === "true"),
    enableLegacyAbac: (_.enableLegacyAbac === "true"),
    initialNodeCount: _.minNodeCount,
    removeDefaultNodePool: true,
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
        autoRepair: (_.autoRepair === "true"),
        autoUpgrade: (_.autoUpgrade === "true"),
    },
    name: "default-pool",
    nodeConfig: {
        diskSizeGb: Number.parseFloat(_.nodeDiskSize),
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
        preemptible: (_.nodePreemptible === "true"),
    },
    nodeCount: _.minNodeCount,
});

// Manufacture a GKE-style Kubeconfig. Note that this is slightly "different" because of the way GKE requires
// gcloud to be in the picture for cluster authentication (rather than using the client cert/key directly).
const k8sConfig = pulumi.
    all([cluster.name, cluster.endpoint, cluster.masterAuth]).
    apply(([name, endpoint, auth]) => {
        const context = `${gcp.config.project}_${gcp.config.zone}_${_.clusterName} `;
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

// Export a Kubernetes provider instance that uses our cluster from above.
const k8sProvider = new k8s.Provider("gkeK8s", {
    kubeconfig: k8sConfig,
});

export { k8sProvider };

