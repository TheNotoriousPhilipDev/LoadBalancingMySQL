#!/bin/bash

NODE_IP=$1
NODE_NAME=$2
INSTALL_NGINX=$3

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y mariadb-server galera-3 rsync nginx

# Stop MySQL to configure Galera
sudo systemctl stop mysql

# Configure Galera settings
sudo cat <<EOF > /etc/mysql/conf.d/galera.cnf
[mysqld]
binlog_format=ROW
default_storage_engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_name="my_galera_cluster"
wsrep_cluster_address="gcomm://192.168.60.11,192.168.60.12,192.168.60.13"
wsrep_node_address="${NODE_IP}"
wsrep_node_name="${NODE_NAME}"
wsrep_sst_method=rsync
EOF

# Start the Galera cluster
if [ "$NODE_NAME" == "node1" ]; then
  sudo galera_new_cluster
else
  sudo systemctl start mysql
fi

# Enable MySQL service on boot
sudo systemctl enable mysql
sudo systemctl restart mysql

# If this is the node with NGINX, configure NGINX as the load balancer
if [ "$INSTALL_NGINX" == "nginx" ]; then
  sudo apt-get install -y nginx

  # Configure NGINX for TCP load balancing
  sudo cat <<EOF > /etc/nginx/nginx.conf
stream {
    upstream galera_cluster {
        server 192.168.60.11:3306;
        server 192.168.60.12:3306;
        server 192.168.60.13:3306;
    }

    server {
        listen 3306;
        proxy_pass galera_cluster;
        health_check interval=3s rise=2 fall=5 timeout=2s;
    }
}

http {
    server {
        listen 8080;
        location /status {
            api;
            allow 192.168.60.0/24;
            deny all;
        }
    }
}
EOF

  # Reload NGINX
  sudo systemctl restart nginx
fi
