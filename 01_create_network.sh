# Create networks
gcloud compute networks create $PRIV_NETWORK_NAME --subnet-mode custom --bgp-routing-mode global -q
gcloud compute networks create $PUB_NETWORK_NAME --subnet-mode custom --bgp-routing-mode global -q

# Create subnets in TAP Airgapped network
gcloud compute networks subnets create $TAP_SUBNET \
--network $PRIV_NETWORK_NAME \
--range $TAP_SUBNET_RANGE \
--region $GCP_REGION --enable-flow-logs \
--enable-private-ip-google-access

gcloud compute networks subnets create $SRV_SUBNET \
--network $PRIV_NETWORK_NAME \
--range $SRV_SUBNET_RANGE \
--region $GCP_REGION --enable-flow-logs \
--enable-private-ip-google-access

gcloud compute networks subnets create $WS_SUBNET \
--network $PRIV_NETWORK_NAME \
--range $WS_SUBNET_RANGE \
--region $GCP_REGION --enable-flow-logs \
--enable-private-ip-google-access

gcloud compute networks subnets create $PUB_SUBNET \
--network $PUB_NETWORK_NAME \
--range $PUB_SUBNET_RANGE \
--region $GCP_REGION --enable-flow-logs \
--enable-private-ip-google-access

# Rule to allow SSHing into Jump box
gcloud compute firewall-rules create allow-ssh-pub \
--network $PUB_NETWORK_NAME --allow tcp:22 --source-ranges 0.0.0.0/0 --direction INGRESS

gcloud compute firewall-rules create allow-ssh-priv \
--network $PRIV_NETWORK_NAME --allow tcp:22 --source-ranges 10.10.0.0/16 --direction INGRESS

gcloud compute firewall-rules create allow-https-priv \
--network $PRIV_NETWORK_NAME --allow tcp:443 --source-ranges 10.10.0.0/16 --direction INGRESS

gcloud compute firewall-rules create allow-https-priv-egress \
--network $PRIV_NETWORK_NAME --allow tcp:443 --destination-ranges 10.10.0.0/16 --direction EGRESS

gcloud compute firewall-rules create allow-https-dns \
--network $PRIV_NETWORK_NAME --allow tcp:53 --destination-ranges 0.0.0.0/0 --direction EGRESS

# Peering
gcloud compute networks peerings create airgapped-peer \
--network=$PUB_NETWORK_NAME --peer-project $GCP_PROJECT --peer-network $PRIV_NETWORK_NAME

gcloud compute networks peerings create airgapped-peer \
--network=$PRIV_NETWORK_NAME --peer-project $GCP_PROJECT --peer-network $PUB_NETWORK_NAME

# Create Private DNS entries
gcloud dns --project=$GCP_PROJECT managed-zones create $DNS_NAME \
--description="Airgapped TAP DNS private zone" \
--dns-name="$DNS_ZONE." \
--visibility="private" \
--networks="$PUB_NETWORK_NAME","$PRIV_NETWORK_NAME"
