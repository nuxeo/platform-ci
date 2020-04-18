import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "../config";
import * as _ from "../control-plane/config"

export const env = _.env;
export const org = _.org;
export const clusterName = _.clusterName;

const providedOptions: _.NodePoolOptions = _.config.requireObject('controlPlane');

export const controlPlane: ControlPlaneOptions = {
    ... {
        enableKubernetesAlpha: false,
        enableLegacyAbac: false,
        nodePool: {
            imageType: 'COS-CONTAINERD',
            machineType: 'n1-standard-8',
            nodePreemptible: false,
            autoRepair: true,
            autoUpgrade: true,
            nodeDiskSize: 100,
            minNodeCount: 1,
            maxNodeCount: 2
        }
    }, ...providedOptions
};

export const nodeMachineType = _.stringPropertyOf("nodeMachineType", () => "e2-standard-16");
export const imageType = _.stringPropertyOf("imageType", () => "COS_CONTAINERD");
export const minNodeCount = _.numberPropertyOf("minNodeCount", () => 1);
export const maxNodeCount = _.numberPropertyOf("maxNodeCount", () => 3);
export const nodePreemptible = _.booleanPropertyOf("nodePreemptible", () => false);
export const nodeDiskSize = _.numberPropertyOf("nodeDiskSize", () => 100);
export const autoUpgrade = _.booleanPropertyOf("autoUpgrade", () => true);
export const autoRepair = _.booleanPropertyOf("autoRepair", () => true);
