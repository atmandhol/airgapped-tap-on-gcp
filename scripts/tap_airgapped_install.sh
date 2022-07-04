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

# Add custom certs to minikube cluster
mkdir -p $HOME/.minikube/certs
cp registry_server_ca.crt $HOME/.minikube/certs/registry_server_ca.crt
minikube start --embed-certs

# Install cluster essentials
kubectl create namespace kapp-controller

kubectl delete secret harbor-creds -n kapp-controller
kubectl delete secret kapp-controller-config -n kapp-controller

kubectl -n kapp-controller create secret docker-registry harbor-creds --docker-server=$HARBOR_HOST_NAME --docker-username='admin' --docker-password=$HARBOR_ADMIN_PASSWORD

(cd $HOME/cluster_essentials && INSTALL_BUNDLE=$HARBOR_HOST_NAME/library/cluster-essentials-bundle:$CLUSTER_ESSENTIALS_BUNDLE_VERSION \
INSTALL_REGISTRY_HOSTNAME=$HARBOR_HOST_NAME \
INSTALL_REGISTRY_USERNAME=admin \
INSTALL_REGISTRY_PASSWORD=$HARBOR_ADMIN_PASSWORD \
./install.sh -y)

