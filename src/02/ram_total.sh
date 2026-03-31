
ram_total_kb=$(grep -E '^MemTotal:' /proc/meminfo | awk '{print $2}')
ram_total_gb=$(echo "scale=3; $ram_total_kb / 1024 / 1024" | bc)
echo $ram_total_gb