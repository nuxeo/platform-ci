import * as _ from "../config";

export const env = _.env;
export const org = _.org;
export const clusterName = _.clusterName;
export const createdBy = _.createdBy;
export const createdTimestamp = _.createdTimestamp;

export const withStackReferenceProvider = _.withStackReferenceProvider;

export interface ControlPlaneOptions {
    masterVersion: string;
    enableKubernetesAlpha: boolean;
    enableLegacyAbac: boolean;

    nodePool: NodePoolOptions;
}

export interface NodePoolOptions {
    imageType: string;
    machineType: string;
    nodePreemptible: boolean;
    autoRepair: boolean;
    autoUpgrade: boolean;
    nodeDiskSize: number;
    minNodeCount: number;
    maxNodeCount: number;
}

const providedOptions: ControlPlaneOptions | undefined = _.config.getObject('controlPlane');
const defaultOptions: ControlPlaneOptions = {
    masterVersion: "1.16",
    enableKubernetesAlpha: false,
    enableLegacyAbac: false,
    nodePool: {
        imageType: 'COS',
        machineType: 'n1-standard-8',
        nodePreemptible: false,
        autoRepair: true,
        autoUpgrade: true,
        nodeDiskSize: 100,
        minNodeCount: 1,
        maxNodeCount: 2
    }
};

export const options = _.Optional.of(providedOptions).or(defaultOptions).get();
