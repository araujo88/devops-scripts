#!/bin/bash

echo "Installing kubectl ..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

MSG=$(echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check)

if [ "$MSG" == "kubectl: OK" ]; then
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    source ~/.bashrc
else
    echo "WARNING: 1 computed checksum did NOT match."
fi
