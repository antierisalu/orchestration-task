#!/bin/bash
# Install K3s on the master node
curl -sfL https://get.k3s.io | sh -

# Make sure kubectl is set up for the vagrant user
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

# Get the token for the worker nodes
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Store the token for the workers to use
echo $TOKEN > /vagrant/token


# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority-data: MEGAPIKKKEY
#     server: https://127.0.0.1:6443
#   name: default
# contexts:
# - context:
#     cluster: default
#     user: default
#   name: default
# current-context: default
# kind: Config
# preferences: {}
# users:
# - name: default
#   user:
#     token: MEGAPIKKKEYjälle