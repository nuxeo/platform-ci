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

export class Optional<T> {
    value: T | undefined;
    orChoice: T | undefined;

    constructor(value: T | undefined) {
        this.value = value;
    }

    static of<T>(value: T | undefined) {
        return new Optional<T>(value);
    }
    or(value: T): Optional<T> {
        this.orChoice = value;
        return this;
    }

    get(): T {
        if (this.value) {
            return this.value;
        }
        if (this.orChoice) {
            return this.orChoice;
        }
        throw "should have a value";
    }
}

export let decode = (input: string): string => Buffer.from(input, 'base64').toString();
export let encode = (input: string): string => Buffer.from(input).toString("base64");

export let env = pulumi.getStack();
export let org = 'nuxeo-platform-jx-bot';
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

