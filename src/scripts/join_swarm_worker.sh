#!/bin/bash

set -e 

TOKEN_FILE="/home/vagrant/scripts/worker_token.txt"
IP_FILE="/home/vagrant/scripts/manager_ip.txt"
TIMEOUT=120 
WAIT_INTERVAL=5 
ELAPSED=0

echo "=== Подготовка к присоединению к Docker Swarm ==="


while ([ ! -f "$TOKEN_FILE" ] || [ ! -f "$IP_FILE" ]) && [ $ELAPSED -lt $TIMEOUT ]; do
    echo "Ожидание файлов токена и IP-адреса менеджера... ($ELAPSED/$TIMEOUT сек)"
    sleep $WAIT_INTERVAL
    ELAPSED=$((ELAPSED + WAIT_INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "Ошибка: Таймаут ожидания файлов $TOKEN_FILE или $IP_FILE."
    echo "Убедитесь, что manager01 успешно инициализировал Swarm."
    exit 1
fi

WORKER_TOKEN=$(cat "$TOKEN_FILE")
MANAGER_IP=$(cat "$IP_FILE")

echo "Получен токен и IP-адрес менеджера."


if docker info | grep -q 'Swarm: active'; then
    echo "Нода уже является частью Swarm кластера."
    
    JOIN_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')
    if [ "$JOIN_STATUS" != "active" ]; then
        echo "Локальное состояние ноды: $JOIN_STATUS. Попытка переподключения..."
        docker swarm leave --force 
    else
        echo "Состояние активно, пропуск присоединения."
        exit 0
    fi
fi


JOIN_CMD="docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"

echo "Выполнение команды присоединения: $JOIN_CMD"
$JOIN_CMD


JOIN_STATUS_TIMEOUT=30
JOIN_CHECK_INTERVAL=3
JOIN_CHECK_ELAPSED=0

while [ $JOIN_CHECK_ELAPSED -lt $JOIN_STATUS_TIMEOUT ]; do
    if docker info | grep -q 'Swarm: active'; then
        if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "active" ]; then
            echo "Успешно присоединено к Swarm кластеру как воркер."
            break
        fi
    fi
    echo "Проверка состояния присоединения... ($JOIN_CHECK_ELAPSED/$JOIN_STATUS_TIMEOUT сек)"
    sleep $JOIN_CHECK_INTERVAL
    JOIN_CHECK_ELAPSED=$((JOIN_CHECK_ELAPSED + $JOIN_CHECK_INTERVAL))
done

if [ $JOIN_CHECK_ELAPSED -ge $JOIN_STATUS_TIMEOUT ]; then
    echo "Предупреждение: Команда 'docker swarm join' выполнена, но статус 'active' не достигнут в течение $JOIN_STATUS_TIMEOUT секунд."
    echo "Проверьте 'docker info' вручную позже. Docker может продолжать попытки в фоне."
fi