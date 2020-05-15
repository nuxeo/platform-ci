import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as controlPlane from "../control-plane/output";

const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-boot` );

export const appsNamespace = new k8s.core.v1.Namespace("jx",
    {
        metadata: {
            name: "jx"
        }
    },
   { provider: k8sProvider });
// { provider: k8sProvider, import "jx" });

export const systemNamespace = new k8s.core.v1.Namespace("jx-system",
    {
        metadata: {
            name: "jx-system"
        }
    },
   { provider: k8sProvider });; 
// { provider: k8sProvider, import "jx-system" });

const gitUrlData: string = _.encode(
    `https://${_.bootSecrets.pipelineUser.username}:${_.bootSecrets.pipelineUser.token}@github.com/${_.githubConfig.owner}/${_.githubConfig.repo}.git`
);

export const gitUrlSecret = new k8s.core.v1.Secret("jx-boot-git-url", 
{
    metadata: {
        name: "jx-boot-git-url",
        namespace: "jx"
    },
    type: "Opaque",
    data: {
        "git-url": gitUrlData
    }},
    { provider: k8sProvider });

const bootSecretsData = _.encode(`secrets:
  adminUser:
    password: ${_.bootSecrets.adminUser.password}
    username: ${_.bootSecrets.adminUser.username}
  hmacToken: ${_.bootSecrets.hmacToken}
  pulumiToken: ${_.bootSecrets.pulumiToken}
  pipelineUser:
    email: ${_.bootSecrets.pipelineUser.email}
    username: ${_.bootSecrets.pipelineUser.username}
    token: ${_.bootSecrets.pipelineUser.token}
  oauth:
    clientId: ${_.bootSecrets.oauth.clientId}
    secret: ${_.bootSecrets.oauth.secret}`);

export const serviceAccount = new gcp.serviceAccount.Account("boot", {
    accountId: accountId,
    displayName: pulumi.interpolate`boot service account for ${clusterName}`,
});
export const serviceAccountKey = new gcp.serviceAccount.Key("boot", {
    publicKeyType: "TYPE_X509_PEM_FILE",
    serviceAccountId: serviceAccount.name,
});
export const ownerBinding = new gcp.serviceAccount.IAMBinding("sa-owner-binding", {
    members: [pulumi.interpolate`serviceAccount:${serviceAccount.email}`],
    role: 'roles/owner',
    serviceAccountId: serviceAccount.name
});
export const workloadIdentityUserBinding = new gcp.serviceAccount.IAMBinding("sa-workload-binding", {
    members: [pulumi.interpolate`serviceAccount:${serviceAccount.email}`],
    role: 'roles/iam.workloadIdentityUser',
    serviceAccountId: serviceAccount.name
});

export const bootSecrets = new k8s.core.v1.Secret("jx-boot-secrets", 
{
    metadata: {
        name: "jx-boot-secrets",
        namespace: "jx",
        labels: { app: "helmboot" },
    },
    type: "Opaque",
    data: {
        'secrets.yaml': bootSecretsData,
        'credentials.json': serviceAccountKey.privateKey
    }},
    { provider: k8sProvider });


