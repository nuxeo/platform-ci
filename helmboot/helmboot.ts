
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

import * as _ from "./config";
import { stackReferenceOf } from "../config";

import { Input, Output, StackReference, output } from "@pulumi/pulumi";
import { Key } from "@pulumi/gcp/serviceAccount";
import { Secret } from "@pulumi/kubernetes/core/v1";
import { resolveProperties } from "@pulumi/pulumi/runtime";

export const namespace = new k8s.core.v1.Namespace("jx",
    {
        metadata: {
            name: "jx"
        }
    }, { aliases: ["urn:pulumi:dev::jxlabs-nos-cluster-boot::kubernetes:core/v1:Namespace::jx"] });

const gitUrlData: string = _.encode(
    `https://${_.secrets.pipelineUser.username}:${_.secrets.pipelineUser.token}@github.com/${_.config.owner}/${_.config.repo}.git`
);

export const gitUrlSecret = new k8s.core.v1.Secret("jx-boot-git-url", {
    metadata: {
        name: "jx-boot-git-url",
        namespace: "jx"
    },
    type: "Opaque",
    data: {
        "git-url": gitUrlData
    }});

const bootSecretsData = _.encode(`secrets:
  adminUser:
    password: ${_.secrets.adminUser.password}
    username: ${_.secrets.adminUser.username}
  hmacToken: ${_.secrets.hmacToken}
  pipelineUser:
    email: ${_.secrets.pipelineUser.email}
    username: ${_.secrets.pipelineUser.username}
    token: ${_.secrets.pipelineUser.token}`);

export const bootSecrets = new k8s.core.v1.Secret("jx-boot-secrets", {
    metadata: {
        name: "jx-boot-secrets",
        namespace: "jx",
        labels: { app: "helmboot" },
    },
    type: "Opaque",
    data: {
        'secrets.yaml': bootSecretsData
    }
});


const controlPlaneReference = stackReferenceOf("control-plane");

function* unwrapProperty(object: Object, name: string) {
    yield Object.getOwnPropertyDescriptor(object, name).get();
}

let cluster = controlPlaneReference.getOutput("cluster").get();
unwrapProperty(cluster, "id");

let unwrapped = value.(value => unwrapProperty(value, name).next).

console.info('*** unwrapped ***'.concat(unwrapped.toString()));