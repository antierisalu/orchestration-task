# orchestrator

"create")
    echo creating resources
    mkdir -p ./k3s
    vagrant up
    echo "Cluster created"
    ;;
"start")
    echo starting cluster
    export KUBECONFIG="./k3s/k3s.yaml"
    KUBECONFIG=${KUBECONFIG} kubectl apply -k .
    KUBECONFIG=${KUBECONFIG} kubectl apply -f ./manifests/
    echo "Cluster started"
    ;;

```
master_ip = "192.168.56.10"
master_host = "k3s-master"
agent_ip = "192.168.56.11"
agent_host = "k3s-agent"
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder "./k3s", "/vagrant"
  config.vm.define "master", primary: true do |master|
    master.vm.network "private_network", ip: master_ip
    master.vm.network "forwarded_port", guest:6443, host:6443
    master.vm.hostname = "master"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    master.vm.provision "shell", inline: <<-SHELL
    sudo -i
    apt-get install -y curl
    INSTALL_K3S_EXEC="--node-ip #{master_ip} --node-external-ip #{master_ip} --flannel-iface=enp0s8"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_NODE_NAME="#{master_host}" K3S_URL="$K3S_URL" sh -
    sleep 5
    cp /var/lib/rancher/k3s/server/token /vagrant/token
    chmod 644 /etc/rancher/k3s/k3s.yaml
    cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s.yaml
    SHELL
  end
  config.vm.define "agent" do |agent|
    agent.vm.network "private_network", ip: agent_ip
    agent.vm.hostname = "agent"
    agent.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
    agent.vm.provision "shell", inline: <<-SHELL
    sudo -i
    apt-get install -y curl
    K3S_TOKEN_FILE=/vagrant/token
    K3S_URL=https://#{master_ip}:6443
    INSTALL_K3S_EXEC="--flannel-iface=enp0s8 --node-ip #{agent_ip} --node-external-ip #{agent_ip}"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_NODE_NAME="#{agent_host}" K3S_URL="$K3S_URL" K3S_TOKEN=$(cat $K3S_TOKEN_FILE) sh -
    SHELL
  end
end
```