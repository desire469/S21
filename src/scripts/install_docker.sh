#!/bin/bash

set -e 
echo "=== Установка Docker ==="

apt-get update

apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions

usermod -aG docker vagrant

systemctl start docker
systemctl enable docker

echo "=== Docker успешно установлен ==="