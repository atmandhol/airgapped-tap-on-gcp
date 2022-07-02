#!/usr/bin/env bash
wget https://github.com/goharbor/harbor/releases/download/$HARBOR_VERSION/harbor-offline-installer-$HARBOR_VERSION.tgz
mv harbor-offline-installer-$HARBOR_VERSION.tgz registry.tgz

gcloud compute scp registry.tgz registry_setup.sh 00_setup.sh $R_VM_NAME:~/ --zone=$R_VM_ZONE --internal-ip
gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" -- 'source 00_setup.sh && sh registry_setup.sh' --internal-ip
export HARBOR_HOST_NAME=$(gcloud compute instances list --filter="$R_VM_NAME" --format "get(networkInterfaces[0].networkIP)").nip.io
gcloud compute scp $R_VM_NAME:~/$HARBOR_HOST_NAME.crt $R_VM_NAME:~/ca.crt . --zone=$R_VM_ZONE --internal-ip
mv ca.crt registry_ca.crt
sudo cp $HARBOR_HOST_NAME.crt /usr/local/share/ca-certificates/$HARBOR_HOST_NAME.crt 
sudo update-ca-certificates

echo "Harbor12345" | docker login $HARBOR_HOST_NAME -u admin --password-stdin

# gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip
