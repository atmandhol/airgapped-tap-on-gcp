# =====================================================
# This env vars needs to be updated to match your setup
# =====================================================
export GCP_PROJECT=adhol-playground
export TANZUNET_USERNAME=adhol@vmware.com
export TANZUNET_PASSWORD=
export CLUSTER_ESSENTIALS_TAR=tanzu-cluster-essentials-linux-amd64-1.1.0.tgz
export CLUSTER_ESSENTIALS_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle:1.1.0
export TANZU_CLI_TAR=tanzu-framework-linux-amd64.tar
export TANZU_CLI_VERSION=v0.11.6
export HARBOR_ADMIN_PASSWORD=Harbor12345

# ================================================
# You can leave all envs vars below this untouched
# ================================================

## Network Setup
export PRIV_NETWORK_NAME=tap-airgapped-network
export PUB_NETWORK_NAME=tap-public-network

## Generic
export GCP_REGION=us-central1
export VM_BASE_IMAGE=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701

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

## Jump VM setup
export JP_VM_NAME=airgapped-jump
export JP_VM_ZONE=us-central1-a
export JP_VM_TYPE=e2-standard-2

## Registry VM setup
export R_VM_NAME=airgapped-registry
export R_VM_ZONE=us-central1-a
export R_VM_TYPE=e2-standard-4
export HARBOR_VERSION=v2.5.1

## TAP Settings
export TAP_K8S_NODE=kindest/node:v1.23.6