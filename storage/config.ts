import * as gcp from "@pulumi/gcp";
import * as _ from "../config";

export let env = _.env;
export let org = _.org;

export let clusterName = _.clusterName;
