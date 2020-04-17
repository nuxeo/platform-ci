import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import { env, org, imageType, autoRepair, autoUpgrade, createdBy, createdTimestamp } from "../config";

const config = new pulumi.Config();

const clusterName = config.get("clusterName") || `jxlabs-nos-${env}`;
const minNodeCount = config.getNumber("minNodeCount") || 0;
const maxNodeCount = config.getNumber("maxNodeCount") || 8;
const nodeMachineType = config.get("nodeMachineType") || "e2-standard-16";
const nodePreemptible = config.get("nodePreemptible") || "false";
const nodeDiskSize = config.get("nodeDiskSize") || "300";

export * from "../config"
export { clusterName, minNodeCount, maxNodeCount, nodeMachineType, nodeDiskSize  };
