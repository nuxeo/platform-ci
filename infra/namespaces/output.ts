import * as pulumi from "@pulumi/pulumi";
import { Output } from "@pulumi/pulumi";
import { withStackReferenceProvider } from "../config";

export class Namespaces {
    appsNamespace: Output<string>
    systemNamespace: Output<string>

    constructor(appsNamespace:Output<string>, systemNamespace:Output<string>) {
        this.appsNamespace = appsNamespace;
        this.systemNamespace = systemNamespace;
    }
}

export const output: Namespaces = withStackReferenceProvider<Namespaces>('namespaces').
    apply(reference => 
            new Namespaces(pulumi.interpolate`${reference.getOutput('appsNamespace').apply(v => v.metadata.name)}`,
                         pulumi.interpolate`${reference.requireOutput('systemNamespace').apply(v => v.metadata.name)}`));

