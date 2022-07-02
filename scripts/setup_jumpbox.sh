#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade -y

# Setup Docker
sudo apt install docker.io -y
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo systemctl restart docker
