import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";
import * as _ from "../config";
import * as controlPlane from "../control-plane/output"

interface AdminUser {
    username: string,
    password: string
}

interface OAuth {
    clientId: string,
    secret: string
}

interface PipelineUser {
    email: string,
    token: string,
    username: string
}

export interface DockerAuth {
    username: string,
    password: string|pulumi.Output<string>,
    url: string
}

interface Docker {
    username: string,
    password: string|pulumi.Output<string>,
    url: string
    auth: DockerAuth[]
}

interface BootSecrets {
    adminUser: AdminUser,
    hmacToken: string,
    pulumiToken: string,
    pipelineUser: PipelineUser,
    oauth: OAuth,
    docker: Docker
}

interface GithubConfig {
    owner: string,
    repo: string
}

export const env = _.env;
export const withStackReferenceOf = _.withStackReferenceOf;
export const githubConfig = _.config.requireObject<GithubConfig>('githubConfig');
export const bootSecrets = _.config.requireObject<BootSecrets>('bootSecrets');
export const k8sProvider = controlPlane.output.k8sProvider;

export let rfc1035 = _.rfc1035;
export let encode = _.encode;
export let decode = _.decode;
