import * as gcp from "@pulumi/gcp";
import { clusterName, keyringName, rfc1035 } from "./config";

export const bucket = new gcp.storage.Bucket("vault", {
    location: gcp.config.region,
    name: `${clusterName}-vault`,
});
export const cryptoKey = new gcp.kms.CryptoKey("vault", {
    keyRing: `projects/build-jx-prod/locations/${gcp.config.region}/keyRings/${clusterName}`,
    rotationPeriod: "100000s",
});
export const serviceAccount = new gcp.serviceAccount.Account("vault", {
    accountId: rfc1035(`${clusterName}-vt`).id(),
    displayName: `Vault service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("vault", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const storageObjectAdminBinding = new gcp.projects.IAMMember("vault-storage-object-admin-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/storage.objectAdmin",
});
export const cloudkmsAdminBinding = new gcp.projects.IAMMember("vault-cloudkms-admin-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcp.config.project}.iam.gserviceaccount.com`,
role: "roles/cloudkms.admin",
});
export const cloudkmsCryptoBinding = new gcp.projects.IAMMember("vault-cloudkms-crypto-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcp.config.project}.iam.gserviceaccount.com`,
    role: "roles/cloudkms.cryptoKeyEncrypterDecrypter",
});
