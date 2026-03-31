echo "HOSTNAME = $(hostname)"

echo "TIMEZONE = $(./timezone.sh)"

echo "USER = $(whoami)"
echo "OS = $(uname -s) $(uname -v | awk '{print $1}')"
echo "DATE = $(date '+%d %b %Y %H:%M:%S')"
echo "UPTIME = $(uptime -p)"

uptime_seconds=$(awk '{printf("%d\n", $1)}' /proc/uptime)

echo "UPTIME_SEC = up for $uptime_seconds seconds"

echo "IP = $(hostname -I | awk '{print $1}')"

echo "MASK = $(./interface.sh)"


gateway=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1)

echo "GATEWAY = ${gateway:-N/A}"

echo "RAM_TOTAL = $(./ram_total.sh) GB"

echo "RAM_USED = $(./ram_used.sh) GB"

echo "RAM_FREE = $(./ram_free.sh) GB"

df_output=$(df -B1 --output=size,used,avail / | tail -1)
total_bytes=$(echo "$df_output" | awk '{print $1}')
used_bytes=$(echo "$df_output" | awk '{print $2}')
free_bytes=$(echo "$df_output" | awk '{print $3}')

space_root_mb=$(echo "scale=2; $total_bytes / 1024 / 1024" | bc)
space_root_used_mb=$(echo "scale=2; $used_bytes / 1024 / 1024" | bc)
space_root_free_mb=$(echo "scale=2; $free_bytes / 1024 / 1024" | bc)

echo "SPACE_ROOT = ${space_root_mb} MB"
echo "SPACE_ROOT_USED = ${space_root_used_mb} MB"
echo "SPACE_ROOT_FREE = ${space_root_free_mb} MB"
