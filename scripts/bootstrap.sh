#!/usr/bin/env bash

# Create DNS records for all the VMs
gcloud dns --project=$GCP_PROJECT record-sets create $R_DNS --type="A" --zone=$DNS_NAME \
--rrdatas=$(gcloud compute instances list --filter="$R_VM_NAME" --format "get(networkInterfaces[0].networkIP)") \
--ttl="60"
gcloud dns --project=$GCP_PROJECT record-sets create $IC_DNS --type="A" --zone=$DNS_NAME \
--rrdatas=$(gcloud compute instances list --filter="$IC_VM_NAME" --format "get(networkInterfaces[0].networkIP)") \
--ttl="60"
gcloud dns --project=$GCP_PROJECT record-sets create $GH_DNS --type="A" --zone=$DNS_NAME \
--rrdatas=$(gcloud compute instances list --filter="$GH_VM_NAME" --format "get(networkInterfaces[0].networkIP)") \
--ttl="60"

# Bootstrap Registry VM
wget https://github.com/goharbor/harbor/releases/download/$HARBOR_VERSION/harbor-offline-installer-$HARBOR_VERSION.tgz
mv harbor-offline-installer-$HARBOR_VERSION.tgz registry.tgz
gcloud compute scp registry.tgz registry_setup.sh 00_setup.sh $R_VM_NAME:~/ --zone=$R_VM_ZONE --internal-ip -q
gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh registry_setup.sh'

# Bootstrap Iterate Cluster VM
gcloud compute scp docker_setup.sh iterate_cluster_setup.sh 00_setup.sh $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'sh docker_setup.sh'
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh iterate_cluster_setup.sh'

# Bootstrap Git VM
gcloud compute scp gitea_setup.sh 00_setup.sh $GH_VM_NAME:~/ --zone=$GH_VM_ZONE --internal-ip
gcloud compute ssh --zone "$GH_VM_ZONE" "$GH_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh gitea_setup.sh'

# Download CA Certs from Registry and Git VMs
gcloud compute scp $R_VM_NAME:~/$R_DNS.crt . --zone=$R_VM_ZONE --internal-ip
gcloud compute scp $GH_VM_NAME:~/$GH_DNS.crt . --zone=$GH_VM_ZONE --internal-ip

# Copy Registry CA certs to Iterate Cluster VM
cat <<EOF > install_certs.sh
sudo cp $R_DNS.crt /usr/local/share/ca-certificates/$R_DNS.crt
sudo cp $GH_DNS.crt /usr/local/share/ca-certificates/$GH_DNS.crt
sudo update-ca-certificates
sudo systemctl restart docker
sleep 5
echo "$HARBOR_ADMIN_PASSWORD" | docker login $R_DNS -u admin --password-stdin
EOF
chmod +x install_certs.sh
gcloud compute scp 00_setup.sh install_certs.sh $R_DNS.crt $GH_DNS.crt $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sudo sh install_certs.sh'

# SSH commands:
# source 00_setup.sh && gcloud compute ssh --zone "$R_VM_ZONE" "$R_VM_NAME" --project "$GCP_PROJECT" --internal-ip
# source 00_setup.sh && gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip
# source 00_setup.sh && gcloud compute ssh --zone "$GH_VM_ZONE" "$GH_VM_NAME" --project "$GCP_PROJECT" --internal-ip