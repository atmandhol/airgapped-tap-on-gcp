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

tanzu package repository add tbs-full-deps-repository \
    --url $HARBOR_HOST_NAME/library/tbs-full-deps:$TBS_DEPS_PACKAGE_BUNDLE_VERSION \
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
  ca_cert_data: |
$(awk '{print "    " $0}' registry_server_ca.crt)

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
    ca_cert_data: |
$(awk '{print "      " $0}' registry_server_ca.crt)


profile: iterate
supply_chain: basic

shared:
  ca_cert_data: |
$(awk '{print "    " $0}' registry_server_ca.crt)

EOF

minikube start --embed-certs

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_PACKAGE_BUNDLE_VERSION --values-file tap-values.yaml -n tap-install --wait=false
tanzu package install full-tbs-deps -p full-tbs-deps.tanzu.vmware.com -v $TBS_DEPS_PACKAGE_BUNDLE_VERSION -n tap-install --wait=false

# Kick the full deps app: kctrl app kick --app full-tbs-deps -n tap-install -y
# Kick the TBS app: kctrl app kick --app buildservice -n tap-install -y
# Kick tap install: kctrl app kick --app tap -n tap-install -y
# Kick source controller install: kctrl app kick --app source-controller -n tap-install -y
# Kick tap install: kctrl app kick --app ootb-supply-chain-basic -n tap-install -y

# Get all package installs status: kubectl get pkgi -A
# Look at build service status: kubectl get pkgi buildservice -n tap-install -oyaml
# To get the tap values on the cluster: kubectl get secrets/tap-tap-install-values -n tap-install -o json | jq ".data.\"tap-values.yml\"" | tr -d '"' | base64 --decode