import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "../config";
import * as control_plane from "../control-plane/config";

export const env = _.env;
export const org = _.org;


const providedOptions: control_plane.NodePoolOptions = _.config.requireObject('nodePool');

export const options: control_plane.NodePoolOptions = {
    ... {
        imageType: 'COS_CONTAINERD',
        machineType: 'e2-standard-16',
        nodePreemptible: false,
        autoRepair: true,
        autoUpgrade: true,
        nodeDiskSize: 100,
        minNodeCount: 0,
        maxNodeCount: 8
    }, ...providedOptions
};

export interface ControlPlane {
    clusterName
}

export const controlPlane: ControlPlane = _.withStackReferenceProvider<ControlPlane>('control-plane').apply(reference => {
    return {
        clusterName: pulumi.interpolate`${reference.getOutput('cluster').apply(v => v.name)}`
    }
});
