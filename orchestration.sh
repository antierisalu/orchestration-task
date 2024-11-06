#!/bin/bash

case $1 in
    "create")
        if [ "$(vagrant status | grep 'running')" ]; then
        echo "VM already running"
        exit 1
        fi

        vagrant up
        export KUBECONFIG=$PWD/shared/k3s.yaml
        echo "kubectl config set to $KUBECONFIG"
        echo "You can start cluster with './orchestration.sh start'"
        exit 0

        ;;
    "start")

        if [ ! "$(vagrant status | grep 'running')" ]; then
            echo "VM is not running. Please run './orchestration.sh create' first."
            exit 1
        fi

        echo "Checking if nodes are ready..."

        while ! kubectl get nodes | grep "master" | grep "Ready" || ! kubectl get nodes | grep "agent1" | grep "Ready"; do
            echo "Waiting for the cluster to be ready..."
            sleep 5
        done

        echo "Checking if deployments are already up..."
        
        if kubectl get deployments.apps | grep -q "gateway"; then
            echo "Deployments are already up. Skipping apply commands."
        else
            echo "Applying secrets"
            kubectl apply -f shared/sec
            sleep 1
            echo "Applying manifests"
            kubectl apply -f shared/manifests
            echo "Usually within two minutes pods should be running, check the status with:"
            echo "kubectl get pods"
        fi

        kubectl get pods -o wide
        echo "check pods status again running 'kubectl get pods'"
        exit 0
        ;;

    "stop")

        if [ "$(vagrant status | grep 'poweroff')" ]; then
            echo "VM already turned off, use start to restart or destroy to remove it"
            exit 0
        fi
        vagrant halt
        echo "VMs turned off"
        exit 0
        ;;

    "destroy")

        vagrant destroy -f
        echo "VM destroyed"
        exit 0
        ;;
    *)
        echo "Invalid option. Use 'create', 'start', 'stop', or 'destroy'."
        exit 1
        ;;
esac





