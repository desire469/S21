
ram_free_kb=$(grep -E '^MemFree:' /proc/meminfo | awk '{print $2}')
ram_free_gb=$(echo "scale=3; $ram_free_kb / 1024 / 1024" | bc)
echo $ram_free_gb