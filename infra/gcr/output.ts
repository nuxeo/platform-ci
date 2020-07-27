import * as pulumi from "@pulumi/pulumi";
import { Output, StackReference } from "@pulumi/pulumi";
import { withStackReferenceProvider } from "../config";

export class GoogleContainerRegistry {
    url: string
    password: Output<string>
    username: string

    constructor(password:Output<string>) {
        this.url = "https://gcr.io";
        this.username = "_json_key";
        this.password = password;
    }
}

export const output: GoogleContainerRegistry = withStackReferenceProvider<GoogleContainerRegistry>('gcr').
    apply(reference => 
        new GoogleContainerRegistry(pulumi.interpolate`${reference.getOutput('serviceAccountKey')}`.apply(o => JSON.stringify(o))));
