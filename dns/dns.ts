import * as gcp from "@pulumi/gcp";
import { clusterName, gcpProject, rfc1035 } from "./config";

var serviceAccountId: string = rfc1035(clusterName).id().concat("-dns");

const serviceAccount = new gcp.serviceAccount.Account("dns", {
    accountId: serviceAccountId,
    displayName: `DNS service account for ${clusterName}`
});
const serviceAccountKey = new gcp.serviceAccount.Key("dns", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name
});
const dnsAdminBinding = new gcp.projects.IAMBinding("sa-dns-admin-binding", {
    members: [`serviceAccount:${clusterName}-dns@${gcpProject}.iam.gserviceaccount.com`],
    project: `${gcp.config.project}`,
    role: 'roles/dns.admin'
});
const zone = new gcp.dns.ManagedZone("cluster", {
    dnsName: `${clusterName}.${gcpProject}.build.nuxeo.com.`,
    name: `${gcp.config.project}-${clusterName}`
});
const zone_ns = new gcp.dns.RecordSet("zone-ns", {
    managedZone: gcpProject,
    name: zone.dnsName,
    type: "NS",
    rrdatas: zone.nameServers,
    ttl: 300
})
const letsencryptCAARecord = new gcp.dns.RecordSet("letsencrypt-caa", {
    managedZone: zone.name,
    name: `${clusterName}.${gcpProject}.build.nuxeo.com.`,
    rrdatas: ["0 issue \"letsencrypt.org\""],
    ttl: 300,
    type: "CAA",
});

let nameServers = zone.nameServers;
export { serviceAccountKey, nameServers };

