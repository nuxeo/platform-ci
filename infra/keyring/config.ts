import * as gcp from "@pulumi/gcp";
import * as _ from "../config";
import * as controlPlane from "../control-plane/output";

export let env = _.env;
export let org = _.org;

