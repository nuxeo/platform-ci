import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import { StackReference } from "@pulumi/pulumi";

let config = new pulumi.Config();

export let booleanPropertyOf = (x: string, otherwise: () => boolean): boolean => {
    return config.get(x) === "true" ?
        true :
        otherwise();
}

export let numberPropertyOf = (x: string, otherwise: () => number): number => {
    var value = config.get(x);
    return value ? Number.parseFloat(value) : otherwise();
}

export let stringPropertyOf = (x: string, otherwise: () => string) => {
    var value = config.get(x);
    return value ? value : otherwise();
}

export let stackReferenceOf = (x: string): StackReference => {
    return new StackReference(`${org}/jxlabs-nos-cluster-${x}/${env}`);
}

export let env = pulumi.getStack();
export let org = "nxmatic";
export let createdBy = 'jxlabs-nos-cluster';
export let createdTimestamp = Date.now();
