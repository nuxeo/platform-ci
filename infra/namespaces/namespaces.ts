import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;

export const appsNamespace = new k8s.core.v1.Namespace("jx",
    {
        metadata: {
            name: "jx"
        }
    },
    { provider: k8sProvider });
//  { provider: k8sProvider, import: "jx" });

export const systemNamespace = new k8s.core.v1.Namespace("jx-system",
    {
        metadata: {
            name: "jx-system"
        }
    },
    { provider: k8sProvider });
//  { provider: k8sProvider, import: "jx-system" });

