#!/bin/bash

# Installing k3s agent

HOST="https://192.168.57.10:6443"
TOKEN=$(cat /vagrant/node-token)

echo $HOST
echo $TOKEN

curl -sfL https://get.k3s.io | K3S_NODE_NAME=agent K3S_URL=$HOST K3S_TOKEN=$TOKEN sh - 


# sudo journalctl -u k3s -f
# sudo /usr/local/bin/k3s-agent-uninstall.sh
# curl -sfL https://get.k3s.io | K3S_NODE_NAME=agent K3S_URL=$HOST K3S_TOKEN=$TOKEN sh -
