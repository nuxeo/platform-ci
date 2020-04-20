import * as pulumi from "@pulumi/pulumi";
import * as _ from "../config";

interface AdminUser {
    username: string,
    password: string
}

interface PipelineUser {
    email: string,
    token: string,
    username: string
}

interface BootSecrets {
    adminUser: AdminUser,
    hmacToken: string,
    pipelineUser: PipelineUser
}

interface GithubConfig {
    owner: string,
    repo: string
}

export const env = _.env;
export const githubConfig = _.config.requireObject<GithubConfig>('githubConfig');
export const bootSecrets = _.config.requireObject<BootSecrets>('bootSecrets');
export const k8sProvider = _.k8sProvider();

export let encode = _.encode;
