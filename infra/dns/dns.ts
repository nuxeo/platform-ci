import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import { encode, rfc1035 } from "./config";
import * as controlPlane from "../control-plane/output";
import * as namespaces from "../namespaces/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => rfc1035(v).id()).apply(v => `${v}-dns` );
const systemNamespace = namespaces.output.systemNamespace;

export const serviceAccount = new gcp.serviceAccount.Account("dns", {
    accountId: accountId,
    displayName: pulumi.interpolate`DNS service account for ${clusterName}`
});
export const serviceAccountKey = new gcp.serviceAccount.Key("dns", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name
});
export const dnsAdminMember = new gcp.projects.IAMMember("sa-dns-admin-member", {
    member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
    role: 'roles/dns.admin'
});
export const secret = new k8s.core.v1.Secret("external-dns-gcp-sa",
    {
        metadata: {
            name: "external-dns-gcp-sa",
            namespace: systemNamespace,
            labels: { app: "helmboot" }
        },
        type: "Opaque",
        data: {
            'credentials.json': serviceAccountKey.privateKey
        }
    }, { provider: k8sProvider });

export const zone = new gcp.dns.ManagedZone("cluster", {
    dnsName: pulumi.interpolate`${clusterName}.${gcp.config.project}.build.nuxeo.com.`,
    name: pulumi.interpolate`${gcp.config.project}-${clusterName}`
});
export const zoneNSRecord = new gcp.dns.RecordSet("zone-ns", {
    managedZone: gcp.config.project,
    name: zone.dnsName,
    type: "NS",
    rrdatas: zone.nameServers,
    ttl: 300
})
export const letsencryptCAARecord = new gcp.dns.RecordSet("letsencrypt-caa", {
    managedZone: zone.name,
    name: pulumi.interpolate`${clusterName}.${gcp.config.project}.build.nuxeo.com.`,
    rrdatas: ["0 issue \"letsencrypt.org\""],
    ttl: 300,
    type: "CAA",
});



