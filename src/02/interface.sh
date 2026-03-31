
interface=$(ip route show default 2>/dev/null | awk '/default/ {print $5}' | head -n1)

if [ -z "$interface" ]; then
    interface=$(ip link show | grep -E "^[0-9]+:" | grep -v "lo:" | awk -F: '{print $2}' | tr -d ' ' | head -n1)
fi

if [ -n "$interface" ]; then
    mask_cidr=$(ip -4 addr show dev "$interface" 2>/dev/null | grep -oP '(?<=/)\d+' | head -n1)
    
    if [ -n "$mask_cidr" ]; then
        mask=""
        for i in $(seq 1 4); do
            if [ $mask_cidr -ge 8 ]; then
                mask="${mask}255"
                mask_cidr=$((mask_cidr - 8))
            elif [ $mask_cidr -gt 0 ]; then
                mask_octet=$((256 - 2**(8 - mask_cidr)))
                mask="${mask}${mask_octet}"
                mask_cidr=0
            else
                mask="${mask}0"
            fi
            [ $i -lt 4 ] && mask="${mask}."
        done
        echo "$mask"
    fi
fi
