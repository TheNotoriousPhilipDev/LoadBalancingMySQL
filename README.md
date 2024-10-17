MySQL Galera Cluster with Vagrant and VirtualBox

This project provisions a three-node MySQL Galera Cluster using Vagrant and VirtualBox. The cluster consists of three Ubuntu 22.04 virtual machines, each configured with the necessary MySQL and Galera dependencies for synchronous replication.
Project Overview

The setup includes:

    Vagrantfile: Defines and provisions three VMs for the MySQL Galera Cluster.
    provision.sh: A script that installs MariaDB and Galera on each node and configures the cluster.

Each node in the cluster is capable of receiving read and write requests. The setup can be scaled further or load balanced using NGINX or another proxy to distribute database traffic across the nodes.

Files in the Project
1. Vagrantfile

The Vagrantfile is responsible for defining the virtual machines and setting up the environment. It pulls an Ubuntu 22.04 base image for each VM and assigns a private network IP. During provisioning, it runs the provision.sh script on each machine.

Key Configuration:

    Three VMs (node1, node2, and node3) with static IP addresses.
    Each VM runs MariaDB and is part of a Galera Cluster.
    The provision.sh file is used to configure each node according to its IP and hostname.

2. provision.sh

This shell script installs and configures MySQL and Galera on each VM. It:

    Installs MariaDB, Galera, and dependencies.
    Configures the Galera cluster for synchronous replication across all nodes.
    Starts the cluster on node1 and joins the other nodes to the cluster.

Important Note: node1 initializes the cluster using galera_new_cluster, while the other nodes simply start the MySQL service and join the existing cluster.
Setup Instructions
Prerequisites

Make sure you have the following installed on your host machine:

    Vagrant
    VirtualBox

Steps

    Clone the repository or create the necessary files:
    Create the Vagrantfile in the project directory:
    Create the provision.sh file in the same directory:
Run vagrant up to start the VMs and provision them.

Once the VMs are running, you can SSH into any node:

You can verify that the cluster is working by logging into MySQL on any node:
mysql -u root -p -e "SHOW STATUS LIKE 'wsrep%';"

How the Galera Cluster Works

    The first node (node1) initializes the Galera Cluster using the command galera_new_cluster.
    Other nodes (node2 and node3) join the cluster automatically by connecting to node1.
    All nodes are configured to replicate data synchronously across the cluster, ensuring data consistency.

Future Improvements

    Add NGINX for TCP load balancing to distribute read and write queries across the nodes.
    Add monitoring and alerting to ensure cluster health.
    Automate backups of the MySQL databases.


    
