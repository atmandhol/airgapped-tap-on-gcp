#!/usr/bin/env bash

mv $TANZU_CLI_TAR cli.tar
mv $CLUSTER_ESSENTIALS_TAR cluster_essentials.tgz

# Add the carvel tools to PATH
wget -O- https://carvel.dev/install.sh > install.sh
sudo bash install.sh

# Download all the required stuff so that we can transfer to the airgapped VM

## Download Cluster Essentials
gsutil cp gs://$GCP_STAGING_BUCKET/cluster-essentials-$CLUSTER_ESSENTIALS_BUNDLE_VERSION.tar .

if [ $? -eq 1 ]
then
    # Download from Tanzu Network
    IMGPKG_REGISTRY_HOSTNAME=registry.tanzu.vmware.com \
    IMGPKG_REGISTRY_USERNAME=$TANZUNET_USERNAME \
    IMGPKG_REGISTRY_PASSWORD=$TANZUNET_PASSWORD \
    imgpkg copy \
        -b $CLUSTER_ESSENTIALS_BUNDLE \
        --to-tar cluster-essentials-$CLUSTER_ESSENTIALS_BUNDLE_VERSION.tar \
        --include-non-distributable-layers

    # Stage it for further use
    gsutil cp cluster-essentials-$CLUSTER_ESSENTIALS_BUNDLE_VERSION.tar gs://$GCP_STAGING_BUCKET/
fi

IMGPKG_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
IMGPKG_REGISTRY_USERNAME=admin \
IMGPKG_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
imgpkg copy \
    --tar cluster-essentials-$CLUSTER_ESSENTIALS_BUNDLE_VERSION.tar \
    --to-repo $HARBOR_HOST_NAME/library/cluster-essentials-bundle \
    --include-non-distributable-layers \
    --registry-ca-cert-path $HARBOR_HOST_NAME.crt


## Download TAP Packages
gsutil cp gs://$GCP_STAGING_BUCKET/tap-packages-$TAP_PACKAGE_BUNDLE_VERSION.tar .

if [ $? -eq 1 ]
then
    # Download from Tanzu Network
    IMGPKG_REGISTRY_HOSTNAME=registry.tanzu.vmware.com \
    IMGPKG_REGISTRY_USERNAME=$TANZUNET_USERNAME \
    IMGPKG_REGISTRY_PASSWORD=$TANZUNET_PASSWORD \
    imgpkg copy \
    -b $TAP_PACKAGE_BUNDLE \
    --to-tar tap-packages-$TAP_PACKAGE_BUNDLE_VERSION.tar \
    --include-non-distributable-layers

    # Stage it for further use
    gsutil cp tap-packages-$TAP_PACKAGE_BUNDLE_VERSION.tar gs://$GCP_STAGING_BUCKET/
fi

IMGPKG_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
IMGPKG_REGISTRY_USERNAME=admin \
IMGPKG_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
imgpkg copy \
    --tar tap-packages-$TAP_PACKAGE_BUNDLE_VERSION.tar \
    --to-repo $HARBOR_HOST_NAME/library/tap-packages \
    --include-non-distributable-layers \
    --registry-ca-cert-path $HARBOR_HOST_NAME.crt


## Download TBS Full Deps Packages
gsutil cp gs://$GCP_STAGING_BUCKET/tbs-full-deps-$TBS_DEPS_PACKAGE_BUNDLE_VERSION.tar .

if [ $? -eq 1 ]
then
    # Download from Tanzu Network
    IMGPKG_REGISTRY_HOSTNAME=registry.tanzu.vmware.com \
    IMGPKG_REGISTRY_USERNAME=$TANZUNET_USERNAME \
    IMGPKG_REGISTRY_PASSWORD=$TANZUNET_PASSWORD \
    imgpkg copy \
    -b $TBS_DEPS_PACKAGE_BUNDLE \
    --to-tar tbs-full-deps-$TBS_DEPS_PACKAGE_BUNDLE_VERSION.tar \
    --include-non-distributable-layers

    # Stage it for further use
    gsutil cp tbs-full-deps-$TBS_DEPS_PACKAGE_BUNDLE_VERSION.tar gs://$GCP_STAGING_BUCKET/
fi

IMGPKG_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
IMGPKG_REGISTRY_USERNAME=admin \
IMGPKG_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
imgpkg copy \
    --tar tbs-full-deps-$TBS_DEPS_PACKAGE_BUNDLE_VERSION.tar \
    --to-repo $HARBOR_HOST_NAME/library/tbs-full-deps \
    --include-non-distributable-layers \
    --registry-ca-cert-path $HARBOR_HOST_NAME.crt

# Run TAP Install
gcloud compute scp cli.tar cluster_essentials.tgz 00_setup.sh tap_airgapped_install.sh $IC_VM_NAME:~/ --zone=$IC_VM_ZONE --internal-ip
gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip -- 'source 00_setup.sh && sh tap_airgapped_install.sh'

# SSH commands:
# source 00_setup.sh && gcloud compute ssh --zone "$IC_VM_ZONE" "$IC_VM_NAME" --project "$GCP_PROJECT" --internal-ip
