import * as controlPlane from "./control-plane/output";


import { dns_sa_key, k8sConfig, kaniko_sa_key, vault_sa_key } from "./cluster";

// Export the Kubeconfig so that clients can easily access our cluster.
export let kubeConfig = k8sConfig;
export let kanikoKey = kaniko_sa_key;
export let vaultKey = vault_sa_key;
export let dnsKey = dns_sa_key;
