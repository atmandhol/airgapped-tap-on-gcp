#!/usr/bin/env bash
wget https://github.com/goharbor/harbor/releases/download/$HARBOR_VERSION/harbor-offline-installer-$HARBOR_VERSION.tgz
mv harbor-offline-installer-$HARBOR_VERSION.tgz registry.tgz

gcloud compute scp registry.tgz 00_setup.sh $R_VM_NAME:~/ --zone=$R_VM_ZONE --internal-ip
# gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip
