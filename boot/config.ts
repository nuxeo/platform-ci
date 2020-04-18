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

interface Secrets {
    owner: string,
    adminUser: AdminUser,
    hmacToken: string,
    pipelineUser: PipelineUser
}

export let env = _.env;
export let secrets = _.config.requireObject<Secrets>('secrets');
