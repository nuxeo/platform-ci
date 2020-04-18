import * as gcp from "@pulumi/gcp";
import * as _ from "./config";

const pool = new gcp.container.NodePool("builder", {
    cluster: _.clusterName,
    name: "builder-pool",
    nodeCount: _.minNodeCount,
    autoscaling: {
        maxNodeCount: _.maxNodeCount,
        minNodeCount: _.minNodeCount,
    },
    management: {
        autoRepair: _.autoRepair,
        autoUpgrade: _.autoUpgrade,
    },
    nodeConfig: {
        diskSizeGb: _.nodeDiskSize,
        imageType: _.imageType,
        labels: {
            node: "builder",
        },
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
        taints: [{
            effect: "NO_SCHEDULE",
            key: "node",
            value: "builder",
        }],
    }
});

export { pool };

