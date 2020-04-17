import { k8sConfig } from "./control-plane";

// Export the Kubeconfig so that clients can easily access our cluster.
export let kubeConfig = k8sConfig;
