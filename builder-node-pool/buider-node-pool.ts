import * as gcp from "@pulumi/gcp";
import * as pulimi from "@pulumi/pulumi";
import { env, org, autoRepair, autoUpgrade, maxNodeCount, minNodeCount, nodeDiskSize, nodeMachineType, imageType, nodePreemptible } from "./config";

const controlPlane = new pulimi.StackReference(`${org}/jxlabs-nos-cluster/${env}`)

const builderNodePool = new gcp.container.NodePool("builder", {
    autoscaling: {
        maxNodeCount: maxNodeCount,
        minNodeCount: minNodeCount,
    },
    cluster: controlPlane.getOutput("cluster"),
    management: {
        autoRepair: (autoRepair === "true"),
        autoUpgrade: (autoUpgrade === "true"),
    },
    name: "builder-pool",
    nodeConfig: {
        diskSizeGb: Number.parseFloat(nodeDiskSize),
        imageType: imageType,
        labels: {
            node: "builder",
        },
        machineType: nodeMachineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: (nodePreemptible === "true"),
        taints: [{
            effect: "NO_SCHEDULE",
            key: "node",
            value: "builder",
        }],
    },
    nodeCount: minNodeCount,
});

export { builderNodePool };
