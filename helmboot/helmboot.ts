import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";

const k8sProvider = controlPlane.output.k8sProvider();

export const namespace = new k8s.core.v1.Namespace("jx",
    {
        metadata: {
            name: "jx"
        }
    },
    { provider: k8sProvider });

const gitUrlData: string = _.encode(
    `https://${_.bootSecrets.pipelineUser.username}:${_.bootSecrets.pipelineUser.token}@github.com/${_.githubConfig.owner}/${_.githubConfig.repo}.git`
);

export const gitUrlSecret = new k8s.core.v1.Secret("jx-boot-git-url", 
{
    metadata: {
        name: "jx-boot-git-url",
        namespace: "jx"
    },
    type: "Opaque",
    data: {
        "git-url": gitUrlData
    }},
    { provider: k8sProvider });

const bootSecretsData = _.encode(`secrets:
  adminUser:
    password: ${_.bootSecrets.adminUser.password}
    username: ${_.bootSecrets.adminUser.username}
  hmacToken: ${_.bootSecrets.hmacToken}
  pipelineUser:
    email: ${_.bootSecrets.pipelineUser.email}
    username: ${_.bootSecrets.pipelineUser.username}
    token: ${_.bootSecrets.pipelineUser.token}`);

export const bootSecrets = new k8s.core.v1.Secret("jx-boot-secrets", 
{
    metadata: {
        name: "jx-boot-secrets",
        namespace: "jx",
        labels: { app: "helmboot" },
    },
    type: "Opaque",
    data: {
        'secrets.yaml': bootSecretsData
    }},
    { provider: k8sProvider });

