## Orchestration-task

This task taught how to deploy multiple applications with two different persistent databases to kubernetes.

#### Prerequisites

* Vagrant
* Virtualbox <= 7.0 because 7.1 does not work with Vagrant out of the box. Vmware should work.
* kubectl

#### Start Virtual Machines

Start VM ```./orchestration.sh create```

Downloads alpine linux image and spins up 2 VMs with one master and one agent node. Could take 2 minutes..

Create Cluster ```./orchestration.sh start```

Downloads application images (~550mb total) from DockerHub, deploys applications and sets the up kubectl configuration. After couple minutes the cluster should be up and ready for testing.

Stop VM if you plan to reboot ```./orchestration.sh stop```

Remove and get rid of everything ```./orchestration.sh destroy```

#### Test access to applications

Send post request to movies database:
```curl -X POST -H "Content-Type: application/json" -d '{"title":"TOP GUN", "description":"Story of a fighter pilot"}' http://192.168.56.10:3000/movies/```

Get the entries from movies database:
```curl http://192.168.56.10:3000/movies```

Send post request to billing database: ```curl -X POST -H "Content-Type: application/json" -d '{"user_id": "22", "number_of_items": "4", "total_amount": "54557"}' http://192.168.56.10:3000/billing```

This is the easy way to check that billing database: ```kubectl exec -it billing-db-0 -- bash -c "psql -U postgres -d billing -c 'SELECT * FROM orders;'"```


[Audit Questions](https://github.com/01-edu/public/tree/master/subjects/devops/orchestrator/audit)

* ##### Does the project as a structure similar to the one below? If not, can the student provide a justification for the chosen project structure?

No, no need for Dockerfiles dir because images are pulled from DockerHub. No need for scripts because they are short enough to be in the Vagrantfile. Manifests and secrets are in secret dir which are shared with between the VMs and host.

* ##### What is container orchestration, and what are its benefits?

It's the automated process of managing and coordinating containers, including their deployment, scaling, networking and lifecycle management. Ensures that containerized applications run efficiently and reliably in a distributed environment.

* ##### What is Kubernetes, and what is its main role?

Open-source container orchestration platform designed to automate the deployment, scaling and management of containerized applications.

* ##### What is K3s, and what is its main role?

Lightweight, certified kubernetes distribution designed for environments with not much resources, such as edge computing, IoT devices and development environments. It has 3 billion lines less code than k8s source code and single binary can be 40mb to 100mb in size and run on less than 512mb of RAM. 

* ##### What is infrastructure as code and what are the advantages of it?

IaC is the practice of managing and provisioning computing infrastructure through machine-readable configuration files, rather than through physical hardware configuration or interactive configuration tools.

* ##### Explain what is a K8s manifest.

A Kubernetes manifest is a YAML or JSON file that defines the desired state of a Kubernetes object, such as a pod, deployment, service, or config map. It specifies the configuration and behavior of the object within the Kubernetes cluster.

* ##### Explain each K8s manifests.

Pod: Smallest and simplest kubernetes object. Represents a single instance of a running process in the cluster.

Deployment: Manages a set of identical pods, ensuring that the specified number of pods are running at all times.

Service: Defines a logical set of pods and a policy by which to access them, often used to expose pods to network traffic.

ConfigMap: Provides a way to inject configuration data into kubernetes pods.

Secret: Used to store and manage sensitive data, such as environment variables, passwords and SSH keys.

PersistentVolume: Represents a piece of storage in the cluster that has been provisioned by and admin or dynamically provisioned using Storage Classes.

PersistenVolumeClain: A request for storage by a user. It is similar to a pod in that pods consume node resources and PVCs consume PV resources.

* ##### What is StatefulSet in K8s?

Kubernetes controller that manages the deployment and scaling of a set of pods, and provides guarantees about the ordering and uniqueness of these pods. It is used for stateful applications that require stable, unique network identifiers and persistent storage.

* ##### What is deployment in K8s?

Kubernetes controller that provides declarative updates to applications. It manages the creation and scaling of a set of identical pods and ensures that a specified number of pods are running at any given time.

* ##### What is the difference between deployment and StatefulSet in K8s?

* #### Deployment:
* Used for stateless applications.
* Pods are interchangeable and do not require stable network identities.
* Scaling and updates are straightforward, with no guarantees about the order of pod creation or deletion.
* #### StatefulSet:

* Used for stateful applications.
* Each pod has a unique, stable network identity and persistent storage.
* Provides guarantees about the ordering and uniqueness of pods, ensuring that pods are created, updated, and deleted in a specific order.

* ##### What is scaling, and why do we use it?

Scaling in Kubernetes refers to the process of adjusting the number of pod replicas running for a particular application. This can be done manually or automatically based on resource usage or other metrics.

* ##### What is a load balancer, and what is its role?

A load balancer is a device or software that distributes network or application traffic across multiple servers. In Kubernetes, a load balancer service exposes an application to the internet and distributes incoming traffic to the backend pods.

* ##### Why we don't put the database as a deployment?

Stateful Nature: Databases require stable, persistent storage and unique network identities, which are not guaranteed by Deployments.

Data Consistency: StatefulSets provide ordered, consistent updates and scaling, which are crucial for maintaining data consistency in databases.

Persistence: StatefulSets ensure that each pod has its own persistent storage, which is essential for databases to retain data across pod restarts and rescheduling.