import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";
import * as namespaces from "../namespaces/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-ko`);
const appsNamespace = namespaces.output.appsNamespace;

export const serviceAccount = new gcp.serviceAccount.Account("kaniko", {
    accountId: accountId,
    displayName: pulumi.interpolate`Kaniko service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("kaniko", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const storageAdminBinding = new gcp.projects.IAMMember("kaniko-storage-admin-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.admin",
});
const kanikoSecretsData = _.encode(`${serviceAccountKey.privateKey}`);

export const kanikoSecret = new k8s.core.v1.Secret("kaniko-secret",
    {
        metadata: {
            name: "kaniko-secret",
            namespace: appsNamespace,
            labels: { app: "helmboot" }
        },
        type: "Opaque",
        data: {
            'kaniko-secret': serviceAccountKey.privateKey
        }
    }, { provider: k8sProvider });
