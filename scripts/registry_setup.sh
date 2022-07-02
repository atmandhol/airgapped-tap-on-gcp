#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install docker.io python3-pip nginx jq docker-compose net-tools -y

tar -xvf registry.tgz

sudo service nginx stop

export HOST_NAME=$(hostname -I | awk '{print $1}').nip.io

# Generate CA Cert private key
openssl genrsa -out ca.key 4096

# Generate the CA certificate.
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$HOST_NAME" \
 -key ca.key \
 -out ca.crt

# Check if its good by running 
openssl x509 -in ca.crt -noout -text

# Generate Server certificate
openssl genrsa -out $HOST_NAME.key 4096

# Generate CSR
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$HOST_NAME" \
    -key $HOST_NAME.key \
    -out $HOST_NAME.csr

# Generate an x509 v3 extension file.
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$HOST_NAME
EOF

# Use the v3.ext file to generate a certificate for your Harbor host

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in $HOST_NAME.csr \
    -out $HOST_NAME.crt

sudo mkdir -p /data
sudo mkdir -p /data/cert
sudo cp $HOST_NAME.crt /data/cert/
sudo cp $HOST_NAME.key /data/cert/

openssl x509 -inform PEM -in $HOST_NAME.crt -out $HOST_NAME.cert

sudo mkdir -p /etc/docker/certs.d
sudo mkdir -p /etc/docker/certs.d/$HOST_NAME/
sudo cp $HOST_NAME.cert /etc/docker/certs.d/$HOST_NAME/
sudo cp $HOST_NAME.key /etc/docker/certs.d/$HOST_NAME/
sudo cp ca.crt /etc/docker/certs.d/$HOST_NAME/

sudo systemctl restart docker

sudo cp $HOST_NAME.crt /usr/local/share/ca-certificates/$HOST_NAME.crt 
sudo update-ca-certificates

cat <<EOF > harbor/harbor.yml
hostname: $HOST_NAME
http:
  port: 80
https:
  port: 443
  certificate: /home/$USER/$HOST_NAME.crt
  private_key: /home/$USER/$HOST_NAME.key

# Change this password to something other than this
harbor_admin_password: Harbor12345

database:
  password: root123
  max_idle_conns: 100
  max_open_conns: 900

data_volume: /data

trivy:
  ignore_unfixed: false
  skip_update: false
  offline_scan: false
  insecure: false

jobservice:
  max_job_workers: 10

notification:
  webhook_job_max_retry: 10

chart:
  absolute_url: disabled

log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /var/log/harbor
_version: 2.5.0

proxy:
  http_proxy:
  https_proxy:
  no_proxy:
  components:
    - core
    - jobservice
    - trivy

upload_purging:
  enabled: true
  age: 168h
  interval: 24h
  dryrun: false
EOF

(cd harbor/ ; sudo ./install.sh)