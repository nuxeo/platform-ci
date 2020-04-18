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

interface BootConfig {
    owner: string,
    repo: string
}

export let env = _.env;
export let config = _.config.requireObject<BootConfig>('boot-config');
export let secrets = _.config.requireObject<BootSecrets>('boot-secrets');
