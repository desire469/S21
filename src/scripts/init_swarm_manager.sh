#!/bin/bash

set -e 

MANAGER_IP=$1

echo "=== Инициализация Docker Swarm на $MANAGER_IP ==="


if ! docker info | grep -q 'Swarm: active'; then
    echo "Инициализация Swarm..."
    docker swarm init --advertise-addr $MANAGER_IP
else
    echo "Swarm уже активен на этой ноде."
fi

docker network create --driver overlay --attachable monitoring
docker network create --driver overlay --attachable shared
docker volume create grafana-storage

WORKER_TOKEN=$(docker swarm join-token -q worker)
MANAGER_TOKEN=$(docker swarm join-token -q manager)



echo "$WORKER_TOKEN" > /vagrant/src/scripts/worker_token.txt
echo "$MANAGER_TOKEN" > /vagrant/src/scripts/manager_token.txt
echo "$MANAGER_IP" > /vagrant/src/scripts/manager_ip.txt

echo "=== Swarm инициализирован ==="
echo "Manager IP: $MANAGER_IP"
echo "Worker token сохранен в /vagrant/scripts/worker_token.txt"
echo "Manager token сохранен в /vagrant/scripts/manager_token.txt"