#!/usr/bin/env bash

# Bootstrap Registry VM
wget https://github.com/goharbor/harbor/releases/download/$HARBOR_VERSION/harbor-offline-installer-$HARBOR_VERSION.tgz
mv harbor-offline-installer-$HARBOR_VERSION.tgz registry.tgz
gcloud compute scp registry.tgz registry_setup.sh 00_setup.sh $R_VM_NAME:~/ --zone=$R_VM_ZONE --internal-ip
gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh registry_setup.sh'

# Bootstrap Iterate Cluster VM
gcloud compute scp docker_setup.sh iterate_cluster_setup.sh 00_setup.sh $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'sh docker_setup.sh'
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh iterate_cluster_setup.sh'

# Download Registry CA Certs from Registry VM
export HARBOR_HOST_NAME=$(gcloud compute instances list --filter="$R_VM_NAME" --format "get(networkInterfaces[0].networkIP)").nip.io
gcloud compute scp $R_VM_NAME:~/$HARBOR_HOST_NAME.crt $R_VM_NAME:~/ca.crt . --zone=$R_VM_ZONE --internal-ip
mv ca.crt registry_ca.crt

# Copy Registry CA certs to Iterate Cluster VM
cat <<EOF > install_certs.sh
sudo cp $HARBOR_HOST_NAME.crt /usr/local/share/ca-certificates/$HARBOR_HOST_NAME.crt
sudo update-ca-certificates
echo "Harbor12345" | docker login $HARBOR_HOST_NAME -u admin --password-stdin
sudo systemctl restart docker
EOF
chmod +x install_certs.sh
gcloud compute scp install_certs.sh $HARBOR_HOST_NAME.crt registry_ca.crt $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'sudo sh install_certs.sh'

# SSH commands:
# source 00_setup.sh && gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip
# source 00_setup.sh && gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip
