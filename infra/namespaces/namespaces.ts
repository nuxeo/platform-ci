import * as k8s from "@pulumi/kubernetes";
import * as controlPlane from "../control-plane/output";

const k8sProvider = controlPlane.output.k8sProvider();

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

