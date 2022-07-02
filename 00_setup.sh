# =====================================================
# This env vars needs to be updated to match your setup
# =====================================================
export GCP_PROJECT=adhol-playground

# ================================================
# You can leave all envs vars below this untouched
# ================================================

## Network Setup
export PRIV_NETWORK_NAME=tap-airgapped-network
export PUB_NETWORK_NAME=tap-public-network

## Generic
export GCP_REGION=us-central1

## Subnet setup
export TAP_SUBNET=tap-subnet
export TAP_SUBNET_RANGE=10.10.10.0/24
export SRV_SUBNET=srv-subnet
export SRV_SUBNET_RANGE=10.10.11.0/24
export WS_SUBNET=ws-subnet
export WS_SUBNET_RANGE=10.10.12.0/24
export PUB_SUBNET=pub-subnet
export PUB_SUBNET_RANGE=10.10.13.0/24


## TAP VMs setup
export IC_VM_NAME=airgapped-iterate-cluster
export IC_VM_ZONE=us-central1-a
export IC_VM_TYPE=e2-standard-16
