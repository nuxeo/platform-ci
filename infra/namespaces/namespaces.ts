import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;

export const appsNamespace = new k8s.core.v1.Namespace("jenkins",
    {
        metadata: {
            name: "jenkins"
        }
    },
   { provider: k8sProvider });
// if the namespace already exists
//  { provider: k8sProvider, import: "jx" });

export const systemNamespace = new k8s.core.v1.Namespace("jenkins-system",
    {
        metadata: {
            name: "jenkins-system"
        }
    },
    { provider: k8sProvider });
// if the namespace already exists
//  { provider: k8sProvider, import: "jx-system" });

