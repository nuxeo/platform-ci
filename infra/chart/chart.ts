import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";
import * as namespaces from "../namespaces/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-chart`);
const appsNamespace = namespaces.output.appsNamespace;

export const bucket = new gcp.storage.Bucket("chart", {
    location: gcp.config.region,
    name: pulumi.interpolate`${clusterName}-charts`,
});
export const serviceAccount = new gcp.serviceAccount.Account("chart", {
    accountId: pulumi.interpolate`${accountId}`,
    displayName: pulumi.interpolate`chart service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("chart", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const serviceAccountSecret = new k8s.core.v1.Secret("chart-sa",
    {
        metadata: {
            name: "chart-sa",
            namespace: appsNamespace,
            labels: { app: "helmboot" }
        },
        type: "Opaque",
        data: {
            'credentials.json': serviceAccountKey.privateKey
        }
    }, { provider: k8sProvider });
export const storageObjectCreatorBinding = new gcp.projects.IAMMember("chart-storage-object-creator-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.objectCreator",
});
export const storageObjectViewerBinding = new gcp.projects.IAMMember("chart-storage-object-viewer-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.objectViewer",
});
