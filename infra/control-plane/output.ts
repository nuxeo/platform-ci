import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";
import { Output } from "@pulumi/pulumi";
import { withStackReferenceProvider } from "../config";

export class ControlPlane {
    clusterName: Output<string>
    k8sConfig: Output<string>

    constructor(clusterName:Output<string>, k8sConfig:Output<string>) {
        this.clusterName = clusterName;
        this.k8sConfig = k8sConfig;
    }

    k8sProvider ():k8s.Provider {
        return new k8s.Provider("control-plane", {
            kubeconfig: this.k8sConfig
        })
    }
}

export const output: ControlPlane = withStackReferenceProvider<ControlPlane>('control-plane').
    apply(reference => new ControlPlane(pulumi.interpolate`${reference.getOutput('cluster').apply(v => v.name)}`,
        pulumi.interpolate`${reference.requireOutput('k8sConfig')}`));

