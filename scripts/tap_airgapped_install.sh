#!/usr/bin/env bash

# Add the carvel tools to PATH
mkdir -p $HOME/tanzu
mkdir -p $HOME/cluster_essentials
tar -xvf cli.tar -C $HOME/tanzu
tar -xvf cluster_essentials.tgz -C $HOME/cluster_essentials

# Install Tanzu CLI
export TANZU_CLI_NO_INIT=true
(cd $HOME/tanzu && sudo install cli/core/$TANZU_CLI_VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu)
(cd $HOME/tanzu && tanzu plugin install --local cli all)

# Install cluster essentials
kubectl create namespace kapp-controller
kubectl create secret generic kapp-controller-config \
   --namespace kapp-controller \
   --from-file caCerts=registry_server_ca.crt

(cd $HOME/cluster_essentials && INSTALL_BUNDLE=$HARBOR_HOST_NAME/library/cluster-essentials-bundle:1.1.0 \
INSTALL_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
INSTALL_REGISTRY_USERNAME=admin \
INSTALL_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
./install.sh)