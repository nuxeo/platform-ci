import * as _ from "./dns";

export let serviceAccountKey = _.serviceAccountKey;
export let nameServers = _.nameServers;

nameServers.apply(v => console.log(v[0]));
