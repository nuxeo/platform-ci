import * as gcp from "@pulumi/gcp";
import { clusterName, rfc1035 } from "./config";

var serviceAccountId: string = rfc1035(clusterName).id().concat("-dns");

export const serviceAccount = new gcp.serviceAccount.Account("dns", {
    accountId: serviceAccountId,
    displayName: `DNS service account for ${clusterName}`
});
export const serviceAccountKey = new gcp.serviceAccount.Key("dns", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name
});
export const dnsAdminBinding = new gcp.projects.IAMBinding("sa-dns-admin-binding", {
    members: [`serviceAccount:${clusterName}-dns@${gcp.config.project}.iam.gserviceaccount.com`],
    project: `${gcp.config.project}`,
    role: 'roles/dns.admin'
});
export const zone = new gcp.dns.ManagedZone("cluster", {
    dnsName: `${clusterName}.${gcp.config.project}.build.nuxeo.com.`,
    name: `${gcp.config.project}-${clusterName}`
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
    name: `${clusterName}.${gcp.config.project}.build.nuxeo.com.`,
    rrdatas: ["0 issue \"letsencrypt.org\""],
    ttl: 300,
    type: "CAA",
});


