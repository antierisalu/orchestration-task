#!/bin/bash

# 1. Hostnames

sudo tee /etc/hosts > /dev/null <<EOF
192.168.56.10   master.example.com   master
192.168.56.11   worker1.example.com  worker1
EOF

# 2. Disable the swap

sudo swapoff -a
sudo sed -i '/ swap/d' /etc/fstab

# 3. Load the kernel modules

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 4. Set the kernel parameters

sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# 5. Installing containerd and Docker

sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo tee  /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo usermod -aG docker vagrant
newgrp docker
sudo chown vagrant /var/run/docker.sock

sudo docker-compose --version
sudo docker --version

sudo mkdir -p /etc/containerd/
sudo chown vagrant:vagrant /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo chown vagrant:vagrant /home/vagrant/.docker -R
sudo chmod g+rwx "vagrant/.docker" -R

sudo systemctl enable docker.service
sudo systemctl enable containerd.service


