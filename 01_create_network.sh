# Create a network
gcloud compute networks create $PRIV_NETWORK_NAME --subnet-mode custom --bgp-routing-mode global -q

# Add a subnet to the network
gcloud compute networks subnets create $IC_SUBNET \
--network $PRIV_NETWORK_NAME \
--range $IC_SUBNET_RANGE \
--region $GCP_REGION --enable-flow-logs \
--enable-private-ip-google-access \
--secondary-range services=$IC_SERVICES_IP_RANGE,pods=$IC_PODS_IP_RANGE

# Add firewall rule to block all egress traffic
gcloud compute firewall-rules create deny-egress \
--action DENY \
--rules all \
--destination-ranges 0.0.0.0/0 \
--direction EGRESS \
--priority 1100 \
--network $PRIV_NETWORK_NAME

gcloud compute firewall-rules create allow-ssh \
--network $PRIV_NETWORK_NAME --allow tcp:22

# Delete the default route
gcloud compute routes delete $(gcloud compute routes list | grep $PRIV_NETWORK_NAME | grep default-internet-gateway | cut -d " " -f1) -q