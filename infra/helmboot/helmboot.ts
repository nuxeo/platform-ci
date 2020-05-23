import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as _ from "./config";
import * as namespaces from "../namespaces/output";
import * as controlPlane from "../control-plane/output";

const YAML = require('yaml');


const k8sProvider = controlPlane.output.k8sProvider();
const clusterName = controlPlane.output.clusterName;
const accountId = clusterName.apply(v => _.rfc1035(v).id()).apply(v => `${v}-boot`);

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
        }
    },
    { provider: k8sProvider });

const bootSecretsData =
    _.withStackReferenceOf('gcr').
        requireOutput('serviceAccountKey').
        apply(key => JSON.stringify(key.privateKey)).
        apply(json => {
            return {
                url: "https://gcr.io",
                username: "_json_key",
                password: json
            }
        }).
        apply(auth => {
            _.bootSecrets.docker.url = auth.url;
            _.bootSecrets.docker.username = auth.username;
            _.bootSecrets.docker.password = _.decode(auth.password);
            return _.bootSecrets;
        }).
        apply(secrets => {
            _.bootSecrets.docker.auth.forEach(item => {
                if (item.url == secrets.docker.url) {
                    item.password = secrets.docker.password;
                }
            });
            return { secrets: secrets};
        }).
        apply(o => YAML.stringify(o)).
        apply(y => _.encode(y));

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
            namespace: pulumi.interpolate`${namespaces.output.appsNamespace}`,
            labels: { app: "helmboot" },
        },
        type: "Opaque",
        data: {
            'secrets.yaml': bootSecretsData,
            'credentials.json': serviceAccountKey.privateKey
        }
    },
    { provider: k8sProvider });


