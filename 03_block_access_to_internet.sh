# Add firewall rules to block all egress traffic
gcloud compute firewall-rules create deny-egress \
--action DENY \
--rules all \
--destination-ranges 0.0.0.0/0 \
--direction EGRESS \
--priority 1100 \
--network $PRIV_NETWORK_NAME

# Delete the default route to the internet
gcloud compute routes delete $(gcloud compute routes list | grep $PRIV_NETWORK_NAME | grep default-internet-gateway | cut -d " " -f1) -q
