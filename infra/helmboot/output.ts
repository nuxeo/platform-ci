import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";
import { Output, StackReference } from "@pulumi/pulumi";
import { withStackReferenceProvider } from "../config";

export class Helmboot {
    appsNamespace: Output<string>
    systemNamespace: Output<string>

    constructor(appsNamespace:Output<string>, systemNamespace:Output<string>) {
        this.appsNamespace = appsNamespace;
        this.systemNamespace = systemNamespace;
    }
}

export const output: Helmboot = withStackReferenceProvider<Helmboot>('helmboot').
    apply(reference => 
            new Helmboot(pulumi.interpolate`${reference.getOutput('appsNamespace').apply(v => v.metadata.name)}`,
                         pulumi.interpolate`${reference.requireOutput('systemNamespace').apply(v => v.metadata.name)}`));

