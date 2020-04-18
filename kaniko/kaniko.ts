import * as gcp from "@pulumi/gcp";
import { clusterName, rfc1035 } from "./config";

const serviceAccount = new gcp.serviceAccount.Account("kaniko", {
    accountId: rfc1035(`${clusterName}-ko`).id(),
    displayName: `Kaniko service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("kaniko", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
const storageAdminBinding = new gcp.projects.IAMMember("kaniko-storage-admin-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.admin",
});
const storageObjectAdminBinding = new gcp.projects.IAMMember("kaniko-storage-object-admin-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.objectAdmin",
});
const storageOobjectCreatorBinding = new gcp.projects.IAMMember("kaniko-storage-object-creator-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.objectCreator",
});
