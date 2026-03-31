#!/bin/bash
colors=(37  31  32  34  35  30)



for arg in "$@"; do
   if [ -z "${colors[$(( ${arg} - 1))]+x}" ]; then
      echo "Ошибка: индекс $arg вне границ массива"
      echo "Длина массива colors: ${#colors[@]}"
      exit 1
   fi
done

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mHOSTNAME\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(hostname)\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mTIMEZONE\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(../02/timezone.sh)\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mUSER\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(whoami)\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mOS\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(uname -s) $(uname -v | awk '{print $1}')\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mDATE\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(date '+%d %b %Y %H:%M:%S')\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mUPTIME\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(uptime -p)\e[0m"

uptime_seconds=$(awk '{printf("%d\n", $1)}' /proc/uptime)
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mUPTIME_SEC\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))mup for $uptime_seconds seconds\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mIP\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(hostname -I | awk '{print $1}')\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mMASK\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(../02/interface.sh)\e[0m"


gateway=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1)

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mGATEWAY\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m${gateway:-N/A}\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mRAM_TOTAL\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(../02/ram_total.sh) GB\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mRAM_USED\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(../02/ram_used.sh) GB\e[0m"

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mRAM_FREE\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m$(../02/ram_free.sh) GB\e[0m"

df_output=$(df -B1 --output=size,used,avail / | tail -1)
total_bytes=$(echo "$df_output" | awk '{print $1}')
used_bytes=$(echo "$df_output" | awk '{print $2}')
free_bytes=$(echo "$df_output" | awk '{print $3}')

space_root_mb=$(echo "scale=2; $total_bytes / 1024 / 1024" | bc)
space_root_used_mb=$(echo "scale=2; $used_bytes / 1024 / 1024" | bc)
space_root_free_mb=$(echo "scale=2; $free_bytes / 1024 / 1024" | bc)

echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mSPACE_ROOT\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m${space_root_mb} MB\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mSPACE_ROOT_USED\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m${space_root_used_mb} MB\e[0m"
echo -e "\e[${colors[$(( $2 - 1 ))]};$((${colors[$(( $1 - 1 ))]} + 69))mSPACE_ROOT_FREE\e[0m = \e[${colors[$(( $4 - 1 ))]};$((${colors[$(( $3 - 1 ))]} + 69))m${space_root_free_mb} MB\e[0m"
