import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as _ from "./config";

export const serviceAccount = new gcp.serviceAccount.Account("kaniko", {
    accountId: _.rfc1035(`${_.clusterName}-ko`).id(),
    displayName: `Kaniko service account for ${_.clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("kaniko", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const storageAdminBinding = new gcp.projects.IAMMember("kaniko-storage-admin-binding", {
    member: `serviceAccount:${_.clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.admin",
});
export const storageObjectAdminBinding = new gcp.projects.IAMMember("kaniko-storage-object-admin-binding", {
    member: `serviceAccount:${_.clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.objectAdmin",
});
export const storageObjectCreatorBinding = new gcp.projects.IAMMember("kaniko-storage-object-creator-binding", {
    member: `serviceAccount:${_.clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.objectCreator",
});

const kanikoSecretsData = _.encode(serviceAccountKey.privateKey.get()));

export const kanikoSecret = new k8s.core.v1.Secret("kaniko-secret", {
    metadata: {
        name: "kaniko-secret",
        namespace: "jx",
        labels: { app: "helmboot" }
    },
    type: "Opaque",
    data: {
        'kaniko-secret': kanikoSecretsData
    }
});
