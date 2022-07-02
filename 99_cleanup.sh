gcloud compute firewall-rules delete deny-egress -q
gcloud compute networks subnets delete $IC_SUBNET --region $GCP_REGION -q
gcloud compute networks delete $PRIV_NETWORK_NAME -q