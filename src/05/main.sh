#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Использование: $0 <параметр>"
    echo "Параметры:"
    echo "  1 - Все записи, отсортированные по коду ответа"
    echo "  2 - Все уникальные IP, встречающиеся в записях"
    echo "  3 - Все запросы с ошибками (код ответа 4хх или 5хх)"
    echo "  4 - Все уникальные IP, которые встречаются среди ошибочных запросов"
    exit 1
fi

if [[ ! "$1" =~ ^[1-4]$ ]]; then
    echo "Ошибка: параметр должен быть 1, 2, 3 или 4"
    exit 1
fi


log_files=$(ls ../04/access_*.log 2>/dev/null | head -5)
if [ -z "$log_files" ]; then
    echo "Ошибка: не найдены файлы логов ../04/access_*.log"
    exit 1
fi


get_status_code() {
    echo "$1" | awk -F ' - ' '{print $5}'
}


get_ip() {
    echo "$1" | awk -F ' - ' '{print $1}'
}


get_method() {
    echo "$1" | awk -F ' - ' '{print $3}'
}


get_url() {
    echo "$1" | awk -F ' - ' '{print $4}'
}


get_date() {
    echo "$1" | awk -F ' - ' '{print $2}'
}


print_log_entry() {
    local entry="$1"
    local status=$(get_status_code "$entry")
    local ip=$(get_ip "$entry")
    
    
    case $status in
        2*) 
            printf "\033[32m%s\033[0m\n" "$entry"
            ;;
        4*) 
            printf "\033[33m%s\033[0m\n" "$entry"
            ;;
        5*) 
            printf "\033[31m%s\033[0m\n" "$entry"
            ;;
        *)
            echo "$entry"
            ;;
    esac
}


case $1 in
    1)
        
        echo "=== Все записи, отсортированные по коду ответа ==="
        echo ""
        
        
        for file in $log_files; do
            cat "$file"
        done | awk -F ' - ' '{
            
            split($5, parts, " ")
            status = parts[1] + 0
            printf "%04d %s\n", status, $0
        }' | sort -n | sed 's/^[0-9]* //' | while read line; do
            print_log_entry "$line"
        done
        
        total_count=$(for file in $log_files; do cat "$file"; done | wc -l)
        echo ""
        echo "Всего записей: $total_count"
        ;;
        
    2)
        
        echo "=== Все уникальные IP ==="
        echo ""
        
        
        for file in $log_files; do
            awk -F ' - ' '{print $1}' "$file"
        done | sort -t '.' -k1,1n -k2,2n -k3,3n -k4,4n | uniq | while read ip; do
            
            count=0
            for file in $log_files; do
                file_count=$(grep -c "^$ip - " "$file")
                count=$((count + file_count))
            done
            printf "IP: %-15s | Запросов: %d\n" "$ip" "$count"
        done
        
        unique_count=$(for file in $log_files; do awk -F ' - ' '{print $1}' "$file"; done | sort -u | wc -l)
        echo ""
        echo "Всего уникальных IP: $unique_count"
        ;;
        
    3)
        
        echo "=== Запросы с ошибками (4хх и 5хх) ==="
        echo ""
        echo "Коды 4хх - ошибки клиента:"
        echo "  400 - Bad Request (Некорректный запрос)"
        echo "  401 - Unauthorized (Требуется аутентификация)"
        echo "  403 - Forbidden (Доступ запрещен)"
        echo "  404 - Not Found (Ресурс не найден)"
        echo ""
        echo "Коды 5хх - ошибки сервера:"
        echo "  500 - Internal Server Error (Внутренняя ошибка сервера)"
        echo "  501 - Not Implemented (Метод не поддерживается)"
        echo "  502 - Bad Gateway (Ошибка шлюза)"
        echo "  503 - Service Unavailable (Сервис временно недоступен)"
        echo ""
        echo "Список запросов с ошибками:"
        echo ""
        
        
        for file in $log_files; do
            awk -F ' - ' '$5 ~ /^[45][0-9][0-9]$/' "$file"
        done | while read line; do
            print_log_entry "$line"
        done
        
        error_count=0
        for file in $log_files; do
            file_errors=$(awk -F ' - ' '$5 ~ /^[45][0-9][0-9]$/' "$file" | wc -l)
            error_count=$((error_count + file_errors))
        done
        echo ""
        echo "Всего запросов с ошибками: $error_count"
        ;;
        
    4)
        
        echo "=== Уникальные IP с ошибочными запросами ==="
        echo ""
        
        
        error_logs=$(mktemp)
        for file in $log_files; do
            awk -F ' - ' '$5 ~ /^[45][0-9][0-9]$/' "$file" >> "$error_logs"
        done
        
        
        awk -F ' - ' '{print $1}' "$error_logs" | sort -t '.' -k1,1n -k2,2n -k3,3n -k4,4n | uniq | while read ip; do
            
            error_count=$(grep -c "^$ip - " "$error_logs")
            
            
            total_count=0
            for file in $log_files; do
                file_count=$(grep -c "^$ip - " "$file")
                total_count=$((total_count + file_count))
            done
            
            
            if [ $total_count -gt 0 ]; then
                error_percent=$((error_count * 100 / total_count))
            else
                error_percent=0
            fi
            
            printf "IP: %-15s | Ошибок: %d/%d (%d%%)\n" "$ip" "$error_count" "$total_count" "$error_percent"
        done
        
        
        rm -f "$error_logs"
        
        error_ip_count=$(for file in $log_files; do
            awk -F ' - ' '$5 ~ /^[45][0-9][0-9]$/ {print $1}' "$file"
        done | sort -u | wc -l)
        
        echo ""
        echo "Всего IP с ошибками: $error_ip_count"
        ;;
esac