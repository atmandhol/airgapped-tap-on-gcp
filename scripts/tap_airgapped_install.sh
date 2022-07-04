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

kubectl create ns tap-install
tanzu secret registry add tap-registry \
    --server $HARBOR_HOST_NAME \
    --username admin \
    --password $HARBOR_ADMIN_PASSWORD \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes

kubectl create secret generic kapp-controller-config \
   --namespace kapp-controller \
   --from-file caCerts=registry_server_ca.crt

kubectl create secret generic kapp-controller-config \
   --namespace tap-install \
   --from-file caCerts=registry_server_ca.crt

minikube start --embed-certs

tanzu package repository add tanzu-tap-repository \
    --url $HARBOR_HOST_NAME/library/tap-packages:$TAP_PACKAGE_BUNDLE_VERSION \
    --namespace tap-install

# tanzu package repository delete tanzu-tap-repository -n tap-install -y

cat <<EOF > tap-values.yaml 
appliveview_connector:
  backend:
    host: appliveview.127.0.0.1.nip.io
    sslDisabled: 'true'
buildservice:
  # descriptor_name: full
  enable_automatic_dependency_updates: false
  kp_default_repository: $HARBOR_HOST_NAME/library/tbs
  kp_default_repository_username: admin
  kp_default_repository_password: $HARBOR_ADMIN_PASSWORD
  exclude_dependencies: true

ceip_policy_disclosed: true
cnrs:
  provider: local
  domain_name: 127.0.0.1.nip.io

contour:
  envoy:
    service:
      type: NodePort
      nodePorts:
        http: 31080
        https: 31090

metadata_store:
  app_service_type: NodePort

ootb_supply_chain_basic:
  gitops:
    ssh_secret: ''
  registry:
    repository: /library/supplychain
    server: $HARBOR_HOST_NAME
profile: iterate
supply_chain: basic
EOF

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_PACKAGE_BUNDLE_VERSION --values-file tap-values.yaml -n tap-install --wait=false
