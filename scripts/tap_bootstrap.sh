#!/usr/bin/env bash

mv $TANZU_CLI_TAR cli.tar
mv $CLUSTER_ESSENTIALS_TAR cluster_essentials.tgz

# Add the carvel tools to PATH
wget -O- https://carvel.dev/install.sh > install.sh
sudo bash install.sh

# Download all the required stuff so that we can transfer to the airgapped VM

## Download Cluster Essentials
IMGPKG_REGISTRY_HOSTNAME=registry.tanzu.vmware.com \
IMGPKG_REGISTRY_USERNAME=$TANZUNET_USERNAME \
IMGPKG_REGISTRY_PASSWORD=$TANZUNET_PASSWORD \
imgpkg copy \
    -b $CLUSTER_ESSENTIALS_BUNDLE \
    --to-tar cluster-essentials-bundle.tar \
    --include-non-distributable-layers

IMGPKG_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
IMGPKG_REGISTRY_USERNAME=admin \
IMGPKG_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
imgpkg copy \
    --tar cluster-essentials-bundle.tar \
    --to-repo $HARBOR_HOST_NAME/library/cluster-essentials-bundle:$CLUSTER_ESSENTIALS_BUNDLE_VERSION \
    --include-non-distributable-layers \
    --registry-ca-cert-path $HARBOR_HOST_NAME.crt

# This is a ridiculously long package bundle that takes 30-45 mins. I have downloaded it once and then I transferred
# it to my GCP bucket so next time I can just copy it from there. 
# Uncomment this command and add your code to get the tap-packages.tar from your already staged location for faster install
# ============================ For First time downloaders ================================

# IMGPKG_REGISTRY_HOSTNAME=registry.tanzu.vmware.com \
# IMGPKG_REGISTRY_USERNAME=$TANZUNET_USERNAME \
# IMGPKG_REGISTRY_PASSWORD=$TANZUNET_PASSWORD \
# imgpkg copy \
#     -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_PACKAGE_BUNDLE_VERSION \
#     --to-tar tap-packages.tar \
#     --include-non-distributable-layers

# gsutil cp tap-packages.tar gs://{some-private-bucket-in-your-account}/

# ============ For people who have already stored the bundle in their storage ============

# gsutil cp gs://{some-private-bucket-in-your-account}/tap-packages.tar .

gsutil cp gs://adhol-tap-bundles/tap-packages.tar .

# ========================================================================================

IMGPKG_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
IMGPKG_REGISTRY_USERNAME=admin \
IMGPKG_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
imgpkg copy \
    --tar tap-packages.tar \
    --to-repo $HARBOR_HOST_NAME/library/tap-packages \
    --include-non-distributable-layers \
    --registry-ca-cert-path $HARBOR_HOST_NAME.crt

# Run TAP Install
gcloud compute scp cli.tar cluster_essentials.tgz 00_setup.sh tap_airgapped_install.sh $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh tap_airgapped_install.sh'

# SSH commands:
# source 00_setup.sh && gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip
