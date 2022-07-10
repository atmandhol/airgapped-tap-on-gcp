#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install docker.io jq net-tools maven sqlite3 -y

# Install Gitea
wget -O gitea https://dl.gitea.io/gitea/$GITEA_VERSION/gitea-$GITEA_VERSION-linux-amd64
chmod +x gitea

sudo adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --group \
   --disabled-password \
   --home /home/git \
   git

sudo mv gitea /usr/local/bin

sudo mkdir -p /var/lib/gitea/{custom,data,log}
sudo chown -R git:git /var/lib/gitea/
sudo chmod -R 750 /var/lib/gitea/
sudo mkdir /etc/gitea
sudo chown root:git /etc/gitea
sudo chmod 770 /etc/gitea

# Setup gitea as systemctl
sudo wget https://raw.githubusercontent.com/go-gitea/gitea/main/contrib/systemd/gitea.service -P /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now gitea

# Create certs
export HOST_NAME=$GH_DNS
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$HOST_NAME" \
 -key ca.key \
 -out ca.crt
openssl x509 -in ca.crt -noout -text
openssl genrsa -out $HOST_NAME.key 4096
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$HOST_NAME" \
    -key $HOST_NAME.key \
    -out $HOST_NAME.csr
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$HOST_NAME
EOF
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in $HOST_NAME.csr \
    -out $HOST_NAME.crt

openssl x509 -inform PEM -in $HOST_NAME.crt -out $HOST_NAME.cert

sudo cp $HOST_NAME.crt /usr/local/share/ca-certificates/$HOST_NAME.crt 
sudo update-ca-certificates
