# =====================================================
# This env vars needs to be updated to match your setup
# =====================================================
export GCP_PROJECT=adhol-playground
# This variable points to a private bucket that will be used to store downloaded artifacts
# from Tanzu Network so we don't keep going there for pulling bundles and images if it already exists in our GCP bucket.
# The transfer from the bucket is miles faster than getting it from Tanzu Network
# The script will check if the artifacts are available and will download if not
export GCP_STAGING_BUCKET=adhol-tap-bundles
export TANZUNET_USERNAME=adhol@vmware.com
export TANZUNET_PASSWORD=

# Manual downloads from Tanzu Network (For now)
export CLUSTER_ESSENTIALS_TAR=tanzu-cluster-essentials-linux-amd64-1.2.0-rc.1.tgz
export TANZU_CLI_TAR=tanzu-framework-linux-amd64.tar
export TANZU_CLI_VERSION=v0.11.6

# Registry Configuration
export HARBOR_ADMIN_PASSWORD=Harbor12345

# TAP Configuration
export CLUSTER_ESSENTIALS_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle:1.2.0-rc.1
export CLUSTER_ESSENTIALS_BUNDLE_VERSION=1.2.0-rc.1
export TAP_PACKAGE_BUNDLE=registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:1.2.0
export TAP_PACKAGE_BUNDLE_VERSION=1.2.0
export TBS_DEPS_PACKAGE_BUNDLE=registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:1.6.0
export TBS_DEPS_PACKAGE_BUNDLE_VERSION=1.6.0

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

## Gitea VM setup
export GH_VM_NAME=airgapped-git
export GH_VM_ZONE=us-central1-a
export GH_VM_TYPE=e2-standard-2
export GITEA_VERSION=1.16.8

## Harbor Registry VM setup
export R_VM_NAME=airgapped-registry
export R_VM_ZONE=us-central1-a
export R_VM_TYPE=e2-standard-2
export HARBOR_VERSION=v2.5.1

## Kubernetes Settings
export TAP_K8S_VERSION=1.23.6