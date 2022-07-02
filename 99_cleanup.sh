gcloud compute instances delete $IC_VM_NAME --project $GCP_PROJECT --zone $IC_VM_ZONE -q
gcloud compute firewall-rules delete deny-egress -q
gcloud compute firewall-rules delete allow-ssh -q
gcloud compute networks subnets delete $IC_SUBNET --region $GCP_REGION -q
gcloud compute networks delete $PRIV_NETWORK_NAME -q