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


# Add firewall rules to block all egress traffic
gcloud compute firewall-rules create deny-egress \
--action DENY \
--rules all \
--destination-ranges 0.0.0.0/0 \
--direction EGRESS \
--priority 1100 \
--network $PRIV_NETWORK_NAME

# Rule to allow SSHing into Jump box
gcloud compute firewall-rules create allow-ssh-pub \
--network $PUB_NETWORK_NAME --allow tcp:22

gcloud compute firewall-rules create allow-ssh-priv \
--network $PRIV_NETWORK_NAME --allow tcp:22

# Delete the default route to the internet
gcloud compute routes delete $(gcloud compute routes list | grep $PRIV_NETWORK_NAME | grep default-internet-gateway | cut -d " " -f1) -q

# Peering
gcloud compute networks peerings create airgapped-peer \
--network=$PUB_NETWORK_NAME --peer-project $GCP_PROJECT --peer-network $PRIV_NETWORK_NAME

gcloud compute networks peerings create airgapped-peer \
--network=$PRIV_NETWORK_NAME --peer-project $GCP_PROJECT --peer-network $PUB_NETWORK_NAME
