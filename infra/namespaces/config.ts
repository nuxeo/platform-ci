import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";
import * as _ from "../config";
import * as controlPlane from "../control-plane/output"

export const env = _.env;
export const k8sProvider = controlPlane.output.k8sProvider;

export let rfc1035 = _.rfc1035;
export let encode = _.encode;
