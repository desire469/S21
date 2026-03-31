#!/bin/bash

# Скрипт для сбора метрик системы и генерации Prometheus-совместимой страницы

# Директория для хранения HTML-страницы
METRICS_DIR="/var/www/html/metrics"
METRICS_FILE="$METRICS_DIR/metrics.html"
PROMETHEUS_FILE="$METRICS_DIR/metricsPrometheus"

# Создаем директорию, если не существует
mkdir -p $METRICS_DIR

# Функция для получения метрик
collect_metrics() {
    # CPU метрики
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    CPU_COUNT=$(nproc)
    
    # Метрики оперативной памяти
    MEM_TOTAL=$(free -b | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -b | awk '/^Mem:/ {print $3}')
    MEM_AVAILABLE=$(free -b | awk '/^Mem:/ {print $7}')
    MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED/$MEM_TOTAL)*100}")
    
    # Метрики жесткого диска (корневой раздел)
    DISK_TOTAL=$(df -B1 / | awk 'NR==2 {print $2}')
    DISK_USED=$(df -B1 / | awk 'NR==2 {print $3}')
    DISK_AVAILABLE=$(df -B1 / | awk 'NR==2 {print $4}')
    DISK_PERCENT=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    # Дополнительные метрики
    LOAD_AVG=$(cat /proc/loadavg | awk '{print $1","$2","$3}')
    UPTIME=$(cat /proc/uptime | awk '{print $1}')
    
    # Текущее время в формате timestamp
    TIMESTAMP=$(date +%s)000000000
    
    # Генерация HTML-страницы в формате Prometheus
    cat > $METRICS_FILE << EOF
<!DOCTYPE html>
<html>
<head>
    <title>System Metrics</title>
    <meta http-equiv="refresh" content="3">
    <meta charset="utf-8">
</head>
<body>
<pre>
# HELP node_cpu_usage CPU usage percentage
# TYPE node_cpu_usage gauge
node_cpu_usage{instance="$(hostname)"} $CPU_USAGE

# HELP node_cpu_count Total number of CPU cores
# TYPE node_cpu_count gauge
node_cpu_count{instance="$(hostname)"} $CPU_COUNT

# HELP node_memory_total_bytes Total memory in bytes
# TYPE node_memory_total_bytes gauge
node_memory_total_bytes{instance="$(hostname)"} $MEM_TOTAL

# HELP node_memory_used_bytes Used memory in bytes
# TYPE node_memory_used_bytes gauge
node_memory_used_bytes{instance="$(hostname)"} $MEM_USED

# HELP node_memory_available_bytes Available memory in bytes
# TYPE node_memory_available_bytes gauge
node_memory_available_bytes{instance="$(hostname)"} $MEM_AVAILABLE

# HELP node_memory_usage_percentage Memory usage percentage
# TYPE node_memory_usage_percentage gauge
node_memory_usage_percentage{instance="$(hostname)"} $MEM_PERCENT

# HELP node_disk_total_bytes Total disk space in bytes
# TYPE node_disk_total_bytes gauge
node_disk_total_bytes{instance="$(hostname)"} $DISK_TOTAL

# HELP node_disk_used_bytes Used disk space in bytes
# TYPE node_disk_used_bytes gauge
node_disk_used_bytes{instance="$(hostname)"} $DISK_USED

# HELP node_disk_available_bytes Available disk space in bytes
# TYPE node_disk_available_bytes gauge
node_disk_available_bytes{instance="$(hostname)"} $DISK_AVAILABLE

# HELP node_disk_usage_percentage Disk usage percentage
# TYPE node_disk_usage_percentage gauge
node_disk_usage_percentage{instance="$(hostname)"} $DISK_PERCENT

# HELP node_load_average System load average
# TYPE node_load_average gauge
node_load_average{instance="$(hostname)",period="1min"} $(echo $LOAD_AVG | cut -d',' -f1)
node_load_average{instance="$(hostname)",period="5min"} $(echo $LOAD_AVG | cut -d',' -f2)
node_load_average{instance="$(hostname)",period="15min"} $(echo $LOAD_AVG | cut -d',' -f3)

# HELP node_uptime_seconds System uptime in seconds
# TYPE node_uptime_seconds gauge
node_uptime_seconds{instance="$(hostname)"} $UPTIME

# HELP node_timestamp_last_scrape Timestamp of last metrics scrape
# TYPE node_timestamp_last_scrape gauge
node_timestamp_last_scrape{instance="$(hostname)"} $TIMESTAMP
</pre>
</body>
</html>
EOF
    
    # Устанавливаем правильные права доступа
    chmod 644 $METRICS_FILE
    chown www-data:www-data $METRICS_FILE 2>/dev/null || true
    
    echo "Metrics updated at $(date)"

    cat > $PROMETHEUS_FILE << EOF
# HELP node_cpu_usage CPU usage percentage
# TYPE node_cpu_usage gauge
node_cpu_usage{instance="$(hostname)"} $CPU_USAGE

# HELP node_cpu_count Total number of CPU cores
# TYPE node_cpu_count gauge
node_cpu_count{instance="$(hostname)"} $CPU_COUNT

# HELP node_memory_total_bytes Total memory in bytes
# TYPE node_memory_total_bytes gauge
node_memory_total_bytes{instance="$(hostname)"} $MEM_TOTAL

# HELP node_memory_used_bytes Used memory in bytes
# TYPE node_memory_used_bytes gauge
node_memory_used_bytes{instance="$(hostname)"} $MEM_USED

# HELP node_memory_available_bytes Available memory in bytes
# TYPE node_memory_available_bytes gauge
node_memory_available_bytes{instance="$(hostname)"} $MEM_AVAILABLE

# HELP node_memory_usage_percentage Memory usage percentage
# TYPE node_memory_usage_percentage gauge
node_memory_usage_percentage{instance="$(hostname)"} $MEM_PERCENT

# HELP node_disk_total_bytes Total disk space in bytes
# TYPE node_disk_total_bytes gauge
node_disk_total_bytes{instance="$(hostname)"} $DISK_TOTAL

# HELP node_disk_used_bytes Used disk space in bytes
# TYPE node_disk_used_bytes gauge
node_disk_used_bytes{instance="$(hostname)"} $DISK_USED

# HELP node_disk_available_bytes Available disk space in bytes
# TYPE node_disk_available_bytes gauge
node_disk_available_bytes{instance="$(hostname)"} $DISK_AVAILABLE

# HELP node_disk_usage_percentage Disk usage percentage
# TYPE node_disk_usage_percentage gauge
node_disk_usage_percentage{instance="$(hostname)"} $DISK_PERCENT

# HELP node_load_average System load average
# TYPE node_load_average gauge
node_load_average{instance="$(hostname)",period="1min"} $(echo $LOAD_AVG | cut -d',' -f1)
node_load_average{instance="$(hostname)",period="5min"} $(echo $LOAD_AVG | cut -d',' -f2)
node_load_average{instance="$(hostname)",period="15min"} $(echo $LOAD_AVG | cut -d',' -f3)

# HELP node_uptime_seconds System uptime in seconds
# TYPE node_uptime_seconds gauge
node_uptime_seconds{instance="$(hostname)"} $UPTIME

# HELP node_timestamp_last_scrape Timestamp of last metrics scrape
# TYPE node_timestamp_last_scrape gauge
node_timestamp_last_scrape{instance="$(hostname)"} $TIMESTAMP
EOF
   
          # Устанавливаем правильные права доступа
    chmod 644 $PROMETHEUS_FILE
    chown www-data:www-data $PROMETHEUS_FILE 2>/dev/null || true
}

# Основной цикл (обновление каждые 3 секунды)
while true; do
    collect_metrics
    sleep 3
done