INPUT_FILE="settings.conf"
declare -A config
config[0]=1
config[1]=1
config[2]=1
config[3]=1

colors
colors[0]="white"
colors[1]="red"
colors[2]="green"
colors[3]="blue"
colors[4]="purple"
colors[5]="black"

while IFS='=' read -r key value || [ -n "$key" ]; do
    key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        echo $key $value
        if [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]]; then
            continue
        fi
   config[$key]=$value
done < "$INPUT_FILE"

./getInfo.sh ${config[column1_background]} ${config[column1_font_color]} ${config[column2_background]} ${config[column2_font_color]} 
echo "Column 1 background = ${config[column1_background]:-default} (${colors[$((${config[column1_background]:-1} - 1))]})"
echo "Column 1 font color = ${config[column1_font_color]:-default} (${colors[$((${config[column1_font_color]:-1} - 1))]})"
echo "Column 2 background = ${config[column2_background]:-default} (${colors[$((${config[column2_background]:-1} - 1))]})"
echo "Column 2 font color = ${config[column2_font_color]:-default} (${colors[$((${config[column2_font_color]:-1} - 1))]})"