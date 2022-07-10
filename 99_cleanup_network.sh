# Delete DNS Records
gcloud dns --project=$GCP_PROJECT record-sets delete $R_DNS --type="A" --zone=$DNS_NAME
gcloud dns --project=$GCP_PROJECT record-sets delete $GH_DNS --type="A" --zone=$DNS_NAME
gcloud dns --project=$GCP_PROJECT record-sets delete $IC_DNS --type="A" --zone=$DNS_NAME

# Delete the private DNS Zone
gcloud dns --project=$GCP_PROJECT managed-zones delete $DNS_NAME

gcloud compute firewall-rules delete deny-egress -q
gcloud compute firewall-rules delete allow-ssh-pub -q
gcloud compute firewall-rules delete allow-ssh-priv -q
gcloud compute firewall-rules delete allow-https-priv -q
gcloud compute firewall-rules delete allow-https-dns -q
gcloud compute firewall-rules delete allow-https-priv-egress -q
gcloud compute networks peerings delete airgapped-peer --network=$PRIV_NETWORK_NAME
gcloud compute networks peerings delete airgapped-peer --network=$PUB_NETWORK_NAME
gcloud compute networks subnets delete $TAP_SUBNET --region $GCP_REGION -q
gcloud compute networks subnets delete $WS_SUBNET --region $GCP_REGION -q
gcloud compute networks subnets delete $SRV_SUBNET --region $GCP_REGION -q
gcloud compute networks subnets delete $PUB_SUBNET --region $GCP_REGION -q
gcloud compute networks delete $PRIV_NETWORK_NAME -q
gcloud compute networks delete $PUB_NETWORK_NAME -q
