import * as gcp from "@pulumi/gcp";
import * as kms from "@google-cloud/kms";
import * as _ from "../config"
import * as controlPlane from "../control-plane/output";

const clusterName = controlPlane.output.clusterName;

async function createOrImportIfExists(
    project = gcp.config.project,
    location = gcp.config.region
) {
    const client = new kms.KeyManagementServiceClient();
    const parent = client.locationPath(project, location);

    client.listKeyRings({ parent }).
        then(resp => resp[0].find(keyring =>
            keyring.name == `projects/${gcp.config.project}/locations/${gcp.config.region}/keyRings/${_.clusterName}`)).
        then(keyring => keyring.name).
        then(name =>
            new gcp.kms.KeyRing("keyring", {
                location: gcp.config.region,
                name: clusterName,
            }, { import: name }),
            reason => {
                console.log("no keyring");
                return new gcp.kms.KeyRing("keyring",
                    {
                        location: gcp.config.region,
                        name: clusterName
                    });
            });

}

createOrImportIfExists()

