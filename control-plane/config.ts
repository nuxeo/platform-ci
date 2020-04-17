import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

import * as _ from "../config";

const config = new pulumi.Config();

export const env = _.env;
export const org = _.org;
export const clusterName = _.clusterName;
export const masterVersion = config.get("masterVersion") || gcp.container.getEngineVersions().latestMasterVersion;
export const minNodeCount = config.getNumber("minNodeCount") || 1;
export const maxNodeCount = config.getNumber("maxNodeCount") || 3;
export const nodeMachineType = config.get("nodeMachineType") || "n1-standard-8";
export const nodePreemptible = config.get("nodePreemptible") || "false";
export const imageType = _.imageType;
export const nodeDiskSize = config.get("nodeDiskSize") || "100";
export const autoRepair = config.get("autoRepair") || "true";
export const autoUpgrade = config.get("autoUpgrade") || "true";
export const enableKubernetesAlpha = config.get("enableKubernetesAlpha") || "false";
export const enableLegacyAbac = config.get("enableLegacyAbac") || "true";
export const createdBy = _.createdBy;
export const createdTimestamp = _.createdTimestamp;
