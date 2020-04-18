import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as _ from "../config";

export const env = _.env;
export const org = _.org;
export const clusterName = _.clusterName;
export const createdBy = _.createdBy;
export const createdTimestamp = _.createdTimestamp;


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

const providedOptions: ControlPlaneOptions = _.config.requireObject('controlPlane');

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

export const k8sProvider = () => {
    _.withStackReferenceOf('control-node').then(ref =>
        ref.requireOutputValue('k8sconfig')).then(k8sConfig =>
            new k8s.Provider("gkeK8s", {
                kubeconfig: k8sConfig,
            }));
}