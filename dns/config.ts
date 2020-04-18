import * as gcp from "@pulumi/gcp";
import * as _ from "../config";

export let env = _.env;
export let org = _.org;

export function rfc1035(value: string) {
    var input = value
    return {
        id() {
            return input.toLowerCase()
        }
    }
}

export let clusterName = `jxlabs-nos-${env}`
export let gcpProject = gcp.config.project;
