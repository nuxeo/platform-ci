import * as gcp from "@pulumi/gcp";


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
