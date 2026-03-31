
timezone=$(timedatectl show --property=Timezone --value 2>/dev/null || \
           cat /etc/timezone 2>/dev/null || \
           echo "UTC")

offset=$(date +%z 2>/dev/null || echo "+0000")

if [[ $offset =~ ^([+-])([0-9]{2})([0-9]{2})$ ]]; then
    hours=${BASH_REMATCH[2]#0}
    minutes=${BASH_REMATCH[3]}
    if [ "$minutes" = "00" ]; then
        formatted_offset="UTC ${BASH_REMATCH[1]}${hours}"
    elif [ "$minutes" = "30" ]; then
        formatted_offset="UTC ${BASH_REMATCH[1]}${hours}:30"
    else
        formatted_offset="UTC ${BASH_REMATCH[1]}${hours}:${minutes}"
    fi
else
    formatted_offset="UTC +0"
fi
echo "$timezone $formatted_offset"