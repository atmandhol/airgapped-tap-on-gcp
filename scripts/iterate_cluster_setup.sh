#!/usr/bin/env bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
export PATH=$PATH:$HOME

cat <<EOF > config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraPortMappings:
   - containerPort: 31090 # expose port 31090 of the node to port 80 on the host for use later by Contour ingress (envoy)
     hostPort: 443
   - containerPort: 31080 # expose port 31080 of the node to port 80 on the host for use later by Contour ingress (envoy)
     hostPort: 80
EOF

kind create cluster --name tap-iterate --config config.yaml --image $TAP_K8S_NODE
