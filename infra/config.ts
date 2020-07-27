import * as pulumi from "@pulumi/pulumi";

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

interface Cluster {
    prefix: string;
}

const providedClusterOptions: Cluster | undefined = config.getObject('cluster');
const defaultClusterOptions: Cluster = {
    prefix: '',
};
export const clusterOptions = Optional.of(providedClusterOptions).or(defaultClusterOptions).get();

export let decode = (input: string): string => Buffer.from(input, 'base64').toString();
export let encode = (input: string): string => Buffer.from(input).toString("base64");

export let env = pulumi.getStack();
export let org = 'nuxeo-platform-jx-bot';
export let clusterName = `${clusterOptions.prefix}-${env}`;
export let createdBy = 'pulumi';
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
    new StackReference(`${org}/${clusterOptions.prefix}-infra-${name}/${env}`);

