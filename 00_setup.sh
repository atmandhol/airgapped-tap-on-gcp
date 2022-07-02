# =====================================================
# This env vars needs to be updated to match your setup
# =====================================================
export GCP_PROJECT=adhol-playground

# ================================================
# You can leave all envs vars below this untouched
# ================================================

## Network Setup
export PRIV_NETWORK_NAME=tap-airgapped-network

## Generic
export GCP_REGION=us-central1

## Iterate Cluster Subnet setup
export IC_SUBNET=iterate-cluster-subnet
export IC_SUBNET_RANGE=10.10.10.0/24
export IC_SERVICES_IP_RANGE=10.10.11.0/24
export IC_PODS_IP_RANGE=10.1.0.0/16
export IC_VM_NAME=airgapped-iterate-cluster
export IC_VM_ZONE=us-central1-a
export IC_VM_TYPE=e2-standard-16