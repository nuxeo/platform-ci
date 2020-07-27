import * as gcp from "@pulumi/gcp";
import { clusterName } from "./config";

const bucket = new gcp.storage.Bucket("lts", {
    location: gcp.config.region,
    name: `${clusterName}-lts`,
});

export let bucketName = bucket.name;

