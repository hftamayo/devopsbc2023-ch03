#!/bin/bash
apt-get update -y
useradd hftamayo
echo "devops:devops" | chpasswd
echo "hftamayo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
sudo su - hftamayo
sudo apt-get install -y apt-transport-https curl docker.io
sudo apt-get install -y virtualbox virtualbox-ext-pack
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
minikube start --driver=docker -p minikube
