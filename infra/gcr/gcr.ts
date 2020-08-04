import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";
import * as namespaces from "../namespaces/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-gcr`);
const appsNamespace = namespaces.output.appsNamespace;

export const serviceAccount = new gcp.serviceAccount.Account("gcr", {
    accountId: accountId,
    displayName: pulumi.interpolate`gcr service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("gcr", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const serviceAccountSecret = new k8s.core.v1.Secret("gcr-sa-secret",
    {
        metadata: {
            name: "gcr-sa",
            namespace: appsNamespace,
            labels: { app: "helmboot" }
        },
        type: "Opaque",
        data: {
            'credentials.json': serviceAccountKey.privateKey
        }
    }, { provider: k8sProvider });

export const artifactRegistryWriterBinding = new gcp.projects.IAMMember("gcr-writer-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/artifactregistry.writer",
});
export const artifactRegistryReaderBinding = new gcp.projects.IAMMember("gcr-reader-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/artifactregistry.reader",
});
export const storageObjectCreatorBinding = new gcp.projects.IAMMember("gcr-storage-object-creator-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.objectCreator",
});
export const storageObjectViewerBinding = new gcp.projects.IAMMember("gcr-storage-object-viewer-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.objectViewer",
});
