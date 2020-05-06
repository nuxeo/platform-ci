import * as gcp from "@pulumi/gcp";
import { clusterName } from "../config";

export const keyring = new gcp.kms.KeyRing("keyring", {
    location: gcp.config.region,
    name: clusterName,
}, { import: `projects/build-jx-prod/locations/${gcp.config.region}/keyRings/${clusterName}`});
