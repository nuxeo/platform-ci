import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import { Input, Output } from "@pulumi/pulumi";
import * as _ from "./config";

export const namespace = new k8s.core.v1.Namespace("jx",
    {
        metadata: {
            name: "jx"
        }
    }, { aliases: ["urn:pulumi:dev::jxlabs-nos-cluster-boot::kubernetes:core/v1:Namespace::jx"] });

let encode = (input: string): string => Buffer.from(input).toString("base64");


const gitUrlData: string = `https://${_.secrets.pipelineUser.username}:${_.secrets.pipelineUser.token}@github.com/${_.config.owner}/${_.config.repo}.git`;

export const gitUrlSecret = new k8s.core.v1.Secret("jx-boot-git-url", {
    metadata: {
        name: "jx-boot-git-url",
        namespace: "jx"
    },
    type: "Opaque",
    data: {
        "git-url": encode(gitUrlData)
    }
});

const bootSecretsData = `
secrets:
  adminUser:
    password: ${_.secrets.adminUser.password}
    username: ${_.secrets.adminUser.username}
  hmacToken: ${_.secrets.hmacToken}
  pipelineUser:
    email: ${_.secrets.pipelineUser.email}
    username: ${_.secrets.pipelineUser.username}
    token: ${_.secrets.pipelineUser.token}
`
export const bootSecrets = new k8s.core.v1.Secret("jx-boot-secrets", {
    metadata: {
        name: "jx-boot-secrets",
        namespace: "jx",
        labels: { app: "helmboot" },
    },
    type: "Opaque",
    data: {
        'jx-boot-secrets': encode(bootSecretsData)
    }
});
