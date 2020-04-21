import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";

import { StackReference } from "@pulumi/pulumi";

export let config = new pulumi.Config();

export function rfc1035(value: string) {
    var input = value
    return {
        id() {
            return input.toLowerCase()
        }
    }
}

export let encode = (input: string): string => Buffer.from(input).toString("base64");

export let env = pulumi.getStack();
export let org = "nxmatic";
export let clusterName = `jxlabs-nos-${env}`;
export let createdBy = 'jxlabs-nos-cluster';
export let createdTimestamp = Date.now();

export class StackReferenceProvider<T> {
    reference: StackReference;

    constructor(name: string) {
        this.reference = withStackReferenceOf(name);
    }

    apply(func: (reference: StackReference) => T): T {
        return func(this.reference);
    }

}

export function withStackReferenceProvider<T>(name: string): StackReferenceProvider<T> {
    return new StackReferenceProvider(name);
}

export let withStackReferenceOf = (name: string): StackReference =>
    new StackReference(`${org}/jxlabs-nos-infra-${name}/${env}`);

export const k8sProvider = () =>
    new k8s.Provider("gkeK8s", {
        kubeconfig: withStackReferenceOf('control-plane').requireOutputValue('k8sconfig')
    });
