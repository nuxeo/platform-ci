import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

const credentials = config.get("credentials") || ".jenkinsx-sa@build-prod.gke_sa.key.json";
const gcpZone = config.get("gcpZone") || "us-east1-b";
const gcpRegion = config.get("gcpRegion") || "us-east1";
const gcpProject = config.get("gcpProject") || "build-jx-prod";
const clusterName = config.get("clusterName") || "jxlabs-nos";
const teams = config.get("teams") || ["nos"];
const organisation = config.get("organisation") || "nuxeo";
const cloudProvider = config.get("cloudProvider") || "gke";
const minMasterVersion = config.get("minMasterVersion") || "1.15";
const minNodeCount = config.getNumber("minNodeCount") || 1;
const maxNodeCount = config.getNumber("maxNodeCount") || 3;
const imageType = config.get("imageType") || "COS";
const nodeMachineType = config.get("nodeMachineType") || "n1-standard-8";
const nodePreemptible = config.get("nodePreemptible") || "false";
const nodeDiskSize = config.get("nodeDiskSize") || "100";
const builderMinNodeCount = config.getNumber("builderMinNodeCount") || 0;
const builderMaxNodeCount = config.getNumber("builderMaxNodeCount") || 8;
const builderImageType = config.get("builderImageType") || "COS_CONTAINERD";
const builderNodeMachineType = config.get("builderNodeMachineType") || "e2-standard-16";
const builderNodePreemptible = config.get("builderNodePreemptible") || "false";
const builderNodeDiskSize = config.get("builderNodeDiskSize") || "200";
const nodeDevstorageRole = config.get("nodeDevstorageRole") || "https://www.googleapis.com/auth/devstorage.read_only";
const enableKubernetesAlpha = config.get("enableKubernetesAlpha") || "false";
const enableLegacyAbac = config.get("enableLegacyAbac") || "true";
const autoRepair = config.get("autoRepair") || "true";
const autoUpgrade = config.get("autoUpgrade") || "true";
const createdBy = config.get("createdBy") || "jxlabs-nos";
const createdTimestamp = config.get("createdTimestamp") || Date.now();

function rfc1035(value: string) {
    var input = value
    return {
        id() {
            return input.toLowerCase()
        }
    }
}

const cluster = new gcp.container.Cluster("cluster", {
    description: "jx k8s cluster",
    minMasterVersion: minMasterVersion,
    enableKubernetesAlpha: (enableKubernetesAlpha === "true"),
    enableLegacyAbac: (enableLegacyAbac === "true"),
    initialNodeCount: minNodeCount,
    location: gcpZone,
    name: clusterName,
    removeDefaultNodePool: true,
    resourceLabels: {
        "created-by": createdBy,
        "created-with": "terraform",
    },
});
const default_pool = new gcp.container.NodePool("default", {
    autoscaling: {
        maxNodeCount: maxNodeCount,
        minNodeCount: minNodeCount,
    },
    cluster: cluster.name,
    location: gcpZone,
    management: {
        autoRepair: (autoRepair === "true"),
        autoUpgrade: (autoUpgrade === "true"),
    },
    name: "default-pool",
    nodeConfig: {
        diskSizeGb: Number.parseFloat(nodeDiskSize),
        imageType: imageType,
        machineType: nodeMachineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            nodeDevstorageRole,
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: (nodePreemptible === "true"),
    },
    nodeCount: minNodeCount,
});
const builder_pool = new gcp.container.NodePool("builder", {
    autoscaling: {
        maxNodeCount: builderMaxNodeCount,
        minNodeCount: builderMinNodeCount,
    },
    cluster: cluster.name,
    location: gcpZone,
    management: {
        autoRepair: (autoRepair === "true"),
        autoUpgrade: (autoUpgrade === "true"),
    },
    name: "builder-pool",
    nodeConfig: {
        diskSizeGb: Number.parseFloat(builderNodeDiskSize),
        imageType: builderImageType,
        labels: {
            node: "builder",
        },
        machineType: builderNodeMachineType,
        oauthScopes: [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            nodeDevstorageRole,
            "https://www.googleapis.com/auth/service.management",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
        preemptible: (builderNodePreemptible === "true"),
        taints: [{
            effect: "NO_SCHEDULE",
            key: "node",
            value: "builder",
        }],
    },
    nodeCount: builderMinNodeCount,
});
const lts_bucket = new gcp.storage.Bucket("lts", {
    location: gcpRegion,
    name: `${clusterName}-lts`,
});
const kaniko_sa = new gcp.serviceAccount.Account("kaniko", {
    accountId: rfc1035(`${clusterName}-ko`).id(),
    displayName: `Kaniko service account for ${clusterName}`,
});
export const kaniko_sa_key = new gcp.serviceAccount.Key("kaniko", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: kaniko_sa.name,
});
const kaniko_sa_storage_admin_binding = new gcp.projects.IAMMember("kaniko-storage-admin-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/storage.admin",
});
const kaniko_sa_storage_object_admin_binding = new gcp.projects.IAMMember("kaniko-storage-object-admin-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/storage.objectAdmin",
});
const kaniko_sa_storage_object_creator_binding = new gcp.projects.IAMMember("kaniko-storage-object-creator-binding", {
    member: `serviceAccount:${clusterName}-ko@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/storage.objectCreator",
});
const vault_bucket = new gcp.storage.Bucket("vault", {
    location: gcpRegion,
    name: `${clusterName}-vault`,
});
const vault_sa = new gcp.serviceAccount.Account("vault", {
    accountId: rfc1035(`${clusterName}-vt`).id(),
    displayName: `Vault service account for ${clusterName}`,
});
export const vault_sa_key = new gcp.serviceAccount.Key("vault", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: vault_sa.name,
});
const vault_sa_storage_object_admin_binding = new gcp.projects.IAMMember("vault-storage-object-admin-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/storage.objectAdmin",
});
const vault_sa_cloudkms_admin_binding = new gcp.projects.IAMMember("vault-cloudkms-admin-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/cloudkms.admin",
});
const vault_sa_cloudkms_crypto_binding = new gcp.projects.IAMMember("vault-cloudkms-crypto-binding", {
    member: `serviceAccount:${clusterName}-vt@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/cloudkms.cryptoKeyEncrypterDecrypter",
});
const vault_keyring = new gcp.kms.KeyRing("vault", {
    location: gcpRegion,
    name: `${clusterName}`,
});
const vault_crypto_key = new gcp.kms.CryptoKey("vault", {
    keyRing: vault_keyring.selfLink,
    name: `${clusterName}`,
    rotationPeriod: "100000s",
});
const dns_sa = new gcp.serviceAccount.Account("dns", {
    accountId: rfc1035(`${clusterName}-dns`).id(),
    displayName: `DNS service account for ${clusterName}`,
});
export const dns_sa_key = new gcp.serviceAccount.Key("dns", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: dns_sa.name,
});
const dns_sa_dns_admin_binding = new gcp.projects.IAMMember("dns-dns-admin-binding", {
    member: `serviceAccount:${clusterName}-dns@${gcpProject}.iam.gserviceaccount.com`,
    role: "roles/dns.admin",
});
const cluster_dns_zone = new gcp.dns.ManagedZone("cluster", {
    dnsName: `${clusterName}.${gcpProject}.build.nuxeo.com.`,
    name: `${gcpProject}-${clusterName}`,
});
// const cluste_dns_record = new gcp.dns.RecordSet(pulumi.interpolate`${cluster_dns_zone.dnsName}`.{
//     managedZone: "${gcpProject}",
//     name: pulumi.interpolate`${cluster_dns_zone.dnsName`,
//     type: "NS",
//     rrdatas: []
//     ttl: 300
// })
const letsencrypt_caas = new gcp.dns.RecordSet("letsencrypt_caas", {
    managedZone: pulumi.interpolate`${cluster_dns_zone.name}`,
    name: `${clusterName}.${gcpProject}.build.nuxeo.com.`,
    rrdatas: ["0 issue \"letsencrypt.org\""],
    ttl: 300,
    type: "CAA",
});

// Manufacture a GKE-style Kubeconfig. Note that this is slightly "different" because of the way GKE requires
// gcloud to be in the picture for cluster authentication (rather than using the client cert/key directly).
export const k8sConfig = pulumi.
    all([cluster.name, cluster.endpoint, cluster.masterAuth]).
    apply(([name, endpoint, auth]) => {
        const context = `${gcp.config.project} _${gcp.config.zone} _${name} `;
        return `apiVersion: v1
clusters:
- cluster:
certificate - authority - data: ${ auth.clusterCaCertificate}
server: https://${endpoint}
name: ${ context}
contexts:
- context:
cluster: ${ context}
user: ${ context}
name: ${ context}
current - context: ${ context}
kind: Config
preferences: {}
users:
- name: ${ context}
user:
auth - provider:
config:
cmd - args: config config - helper--format = json
cmd - path: gcloud
expiry - key: '{.credential.token_expiry}'
token - key: '{.credential.access_token}'
name: gcp
`;
    });

// Export a Kubernetes provider instance that uses our cluster from above.
export const k8sProvider = new k8s.Provider("gkeK8s", {
    kubeconfig: k8sConfig,
});
