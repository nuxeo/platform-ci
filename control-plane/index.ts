import * as _ from "./control-plane";

// Export the Kubeconfig so that clients can easily access our cluster.
export let kubeConfig = _.k8sConfig;
export let clusterName = _.clusterName;
