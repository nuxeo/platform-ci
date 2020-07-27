import * as pulumi from "@pulumi/pulumi";
import * as _ from "../config";
import * as controlPlane from "../control-plane/output"

interface AdminUser {
    username: string,
    password: string
}

interface JIRA {
    username: string,
    password: string
}

interface Nexus {
    license: string,
    passwords: string
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
    name: string,
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

interface NodejsAuth {
    name: string,
    username: string,
    password: string|pulumi.Output<string>,
    url: string
}

interface Nodejs {
    auth: NodejsAuth
}

interface BootSecrets {
    adminUser: AdminUser,
    hmacToken: string,
    pulumiToken: string,
    pipelineUser: PipelineUser,
    oauth: OAuth,
    jira: JIRA,
    nexus: Nexus,
    mavenSettings: string,
    docker: Docker,
    nodejs: Nodejs
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
