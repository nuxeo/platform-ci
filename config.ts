import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config("jxlabs-nos-cluster-control-plane");

export const env = pulumi.getStack();
export const org = "nxmatic";
export const clusterName = config.get("clusterName") || `jxlabs-nos-${env}`;
export const imageType = config.get("imageType") || "COS_CONTAINERD";
export const createdBy = config.get("createdBy") || "jxlabs-nos-cluster";
export const createdTimestamp = config.get("createdTimestamp") || Date.now();
