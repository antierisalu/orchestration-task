#!/bin/bash

# Installing k3s master

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable traefik --bind-address 192.168.57.10

cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token


