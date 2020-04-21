import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";

export const pool = new gcp.container.NodePool("builder", {
    cluster: _.controlPlane.clusterName,
    name: "builder-pool",
    nodeCount: _.options.minNodeCount,
    autoscaling: {
        maxNodeCount: _.options.maxNodeCount,
        minNodeCount: _.options.minNodeCount,
    },
    management: {
        autoRepair: _.options.autoRepair,
        autoUpgrade: _.options.autoUpgrade,
    },
    nodeConfig: {
        diskSizeGb: _.options.nodeDiskSize,
        imageType: _.options.imageType,
        labels: {
            node: "builder",
        },
        machineType: _.options.machineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: _.options.nodePreemptible,
        taints: [{
            effect: "NO_SCHEDULE",
            key: "node",
            value: "builder",
        }],
    }
});

