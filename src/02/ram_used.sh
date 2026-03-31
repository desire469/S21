
mem_available_kb=$(grep -E '^MemAvailable:' /proc/meminfo | awk '{print $2}')
if [ -z "$mem_available_kb" ]; then
    mem_free=$(grep -E '^MemFree:' /proc/meminfo | awk '{print $2}')
    cached=$(grep -E '^Cached:' /proc/meminfo | awk '{print $2}')
    buffers=$(grep -E '^Buffers:' /proc/meminfo | awk '{print $2}')
    mem_available_kb=$((mem_free + cached + buffers))
fi
ram_total_kb=$(grep -E '^MemTotal:' /proc/meminfo | awk '{print $2}')

ram_used_kb=$((ram_total_kb - mem_available_kb))
ram_used_gb=$(echo "scale=3; $ram_used_kb / 1024 / 1024" | bc)

echo $ram_used_gb