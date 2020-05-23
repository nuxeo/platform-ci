import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as controlPlane from "../control-plane/output";
import * as namespaces from "../namespaces/output";
import * as _ from "./config";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-vt`);
const appsNamespace = namespaces.output.appsNamespace;

export const bucket = new gcp.storage.Bucket("vault", {
    location: gcp.config.region,
    name: pulumi.interpolate`${clusterName}-vault`,
});
export const cryptoKey = new gcp.kms.CryptoKey("vault", {
    keyRing: pulumi.interpolate`projects/build-jx-prod/locations/${gcp.config.region}/keyRings/${clusterName}`,
    rotationPeriod: "100000s",
});
export const serviceAccount = new gcp.serviceAccount.Account("vault", {
    accountId: accountId,
    displayName: pulumi.interpolate`vault service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("vault", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: pulumi.interpolate`${serviceAccount.name}`,
});
export const storageObjectAdminBinding = new gcp.projects.IAMMember("vault-storage-object-admin-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/storage.objectAdmin",
});
export const cloudkmsAdminBinding = new gcp.projects.IAMMember("vault-cloudkms-admin-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/cloudkms.admin",
});
export const cloudkmsCryptoBinding = new gcp.projects.IAMMember("vault-cloudkms-crypto-binding", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: "roles/cloudkms.cryptoKeyEncrypterDecrypter",
});
export const secret = new k8s.core.v1.Secret("vault-sa",
    {
        metadata: {
            name: "vault-sa",
            namespace: appsNamespace,
            labels: { app: "helmboot" }
        },
        type: "Opaque",
        data: {
            'credentials.json': serviceAccountKey.privateKey
        }
    }, { provider: k8sProvider });
