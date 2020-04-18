import * as gcp from "@pulumi/gcp";
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

export let withStackReferenceOf = (x: string): Promise<StackReference> =>
    Promise.resolve(new StackReference(`${org}/jxlabs-nos-infra-${x}/${env}`));


export let env = pulumi.getStack();
export let org = "nxmatic";
export let clusterName = `jxlabs-nos-${env}`;
export let createdBy = 'jxlabs-nos-cluster';
export let createdTimestamp = Date.now();