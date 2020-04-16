import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

function rfc1035(value: string) {
    var input = value
    return {
        id() {
            return input.split('-').join('0').toLowerCase()
        }
    }
}


const credentials = config.get("credentials") || ".jenkinsx-sa@build-prod.gke_sa.key.json";
const gcpZone = config.get("gcpZone") || "us-east1-b";
const gcpRegion = config.get("gcpRegion") || "us-east1";
const gcpProject = config.get("gcpProject") || "build-prod";
const clusterName = config.get("clusterName") || "jxlabs-nos";
const teams = config.get("teams") || ["nos"];
const organisation = config.get("organisation") || "nuxeo";
const cloudProvider = config.get("cloudProvider") || "gke";
const minMasterVersion = config.get("minMasterVersion") || "1.15";
const minNodeCount = config.getNumber("minNodeCount") || 1;
const maxNodeCount = config.getNumber("maxNodeCount") || 3;
const imageType = config.get("imageType") || "cos";
const nodeMachineType = config.get("nodeMachineType") || "n1-standard-8";
const nodePreemptible = config.get("nodePreemptible") || "false";
const nodeDiskSize = config.get("nodeDiskSize") || "100";
const builderMinNodeCount = config.getNumber("builderMinNodeCount") || 0;
const builderMaxNodeCount = config.getNumber("builderMaxNodeCount") || 8;
const builderImageType = config.get("builderImageType") || "cos_containerd";
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

const cloudresourcemanager_api = new gcp.projects.Service("cloudresourcemanager-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "cloudresourcemanager.googleapis.com",
});
const compute_api = new gcp.projects.Service("compute-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "compute.googleapis.com",
});
const iam_api = new gcp.projects.Service("iam-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "iam.googleapis.com",
});
const cloudbuild_api = new gcp.projects.Service("cloudbuild-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "cloudbuild.googleapis.com",
});
const containerregistry_api = new gcp.projects.Service("containerregistry-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "containerregistry.googleapis.com",
});
const containeranalysis_api = new gcp.projects.Service("containeranalysis-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "containeranalysis.googleapis.com",
});
const cloudkms_api = new gcp.projects.Service("cloudkms-api", {
    disableOnDestroy: false,
    project: gcpProject,
    service: "cloudkms.googleapis.com",
});
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
const default_pool = new gcp.container.NodePool("default-pool", {
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
const builder_pool = new gcp.container.NodePool("builder-pool", {
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
const lts_bucket = new gcp.storage.Bucket("lts-bucket", {
    location: gcpRegion,
    name: `${clusterName}-lts`,
});
const kaniko_sa = new gcp.serviceAccount.Account("kaniko-sa", {
    accountId: rfc1035(`${clusterName}-ko`).id(), displayName: `Kaniko service account for ${clusterName}`,
});
const kaniko_sa_key = new gcp.serviceAccount.Key("kaniko-sa-key", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: kaniko_sa.name,
});
const kaniko_sa_storage_admin_binding = new gcp.projects.IAMMember("kaniko-sa-storage-admin-binding", {
    member: `serviceAccount: ${kaniko_sa.email}`,
    role: "roles/storage.admin",
});
const kaniko_sa_storage_object_admin_binding = new gcp.projects.IAMMember("kaniko-sa-storage-object-admin-binding", {
    member: `serviceAccount: ${kaniko_sa.email}`,
    role: "roles/storage.objectAdmin",
});
const kaniko_sa_storage_object_creator_binding = new gcp.projects.IAMMember("kaniko-sa-storage-object-creator-binding", {
    member: `serviceAccount: ${kaniko_sa.email}`,
    role: "roles/storage.objectCreator",
});
const vault_bucket = new gcp.storage.Bucket("vault-bucket", {
    location: gcpRegion,
    name: `${clusterName}-vault`,
});
const vault_sa = new gcp.serviceAccount.Account("vault-sa", {
    accountId: rfc1035(`${clusterName}-vt`).id(),
    displayName: `Vault service account for ${clusterName}`,
});
const vault_sa_key = new gcp.serviceAccount.Key("vault-sa-key", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: vault_sa.name,
});
const vault_sa_storage_object_admin_binding = new gcp.projects.IAMMember("vault-sa-storage-object-admin-binding", {
    member: pulumi.interpolate`serviceAccount: ${vault_sa.email}`,
    role: "roles/storage.objectAdmin",
});
const vault_sa_cloudkms_admin_binding = new gcp.projects.IAMMember("vault-sa-cloudkms-admin-binding", {
    member: pulumi.interpolate`serviceAccount: ${vault_sa.email}`,
    role: "roles/cloudkms.admin",
});
const vault_sa_cloudkms_crypto_binding = new gcp.projects.IAMMember("vault-sa-cloudkms-crypto-binding", {
    member: pulumi.interpolate`serviceAccount: ${vault_sa.email}`,
    role: "roles/cloudkms.cryptoKeyEncrypterDecrypter",
});
const vault_keyring = new gcp.kms.KeyRing("vault-keyring", {
    location: gcpRegion,
    name: `${clusterName}-keyring`,
}, { import: "projects/build-jx-prod/locations/us-east1/keyRings/jxlabs-nos-keyring" });
const vault_crypto_key = new gcp.kms.CryptoKey("vault-crypto-key", {
    keyRing: vault_keyring.selfLink,
    name: `${clusterName}-crypto-key`,
    rotationPeriod: "100000s",
});
const dns_sa = new gcp.serviceAccount.Account("dns-sa", {
    accountId: rfc1035(`${clusterName}-dns`).id(),
    displayName: `DNS service account for ${clusterName}`,
});
const dns_sa_key = new gcp.serviceAccount.Key("dns-sa-key", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: dns_sa.name,
});
const dns_sa_dns_admin_binding = new gcp.projects.IAMMember("dns-sa-dns-admin-binding", {
    member: pulumi.interpolate`serviceAccount: ${dns_sa.email}`,
    role: "roles/dns.admin",
});
const cluster_dns_zone = new gcp.dns.ManagedZone("cluster-dns-zone", {
    dnsName: `${clusterName}.${gcpProject}.build.nuxeo.com.`,
    name: `${gcpProject}-${clusterName}`,
});
const letsencryptCaas = new gcp.dns.RecordSet("letsencrypt_caas", {
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
certificate-authority-data: ${ auth.clusterCaCertificate}
server: https://${endpoint}
name: ${ context}
contexts:
- context:
cluster: ${ context}
user: ${ context}
name: ${ context}
current-context: ${ context}
kind: Config
preferences: { }
users:
- name: ${ context}
user:
auth-provider:
config:
cmd-args: config config-helper--format = json
cmd-path: gcloud
expiry-key: '{.credential.token_expiry}'
token-key: '{.credential.access_token}'
name: gcp
    `;
    });

// Export a Kubernetes provider instance that uses our cluster from above.
export const k8sProvider = new k8s.Provider("gkeK8s", {
    kubeconfig: k8sConfig,
});
