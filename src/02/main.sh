#!/bin/bash


LOG_FILE="filesystem_creation_$(date +%d:%m:%y.%H:%M:%S).log"

START_TIME=$(date +%s)
START_TIME_READABLE=$(date +"%Y-%m-%d %H:%M:%S")

log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

check_free_space() {
    local free_space_kb=$(df / | awk 'NR==2 {print $4}')
    local free_space_mb=$((free_space_kb / 1024))
    echo $free_space_mb
}

generate_name() {
    local chars="$1"
    local date_suffix="_$(date +%d%m%y)"
    
     final_string=""
   for (( i = 0; i < ${#chars}; i++ )); do
      if (( i == ${#chars}-1 )); then
         if [ ${#final_string} -lt 3 ]; then
            for (( j = 0; j < 4-${#final_string}; j++ )); do
               final_string+="${chars:i:1}"
            done
         fi
      fi
      for (( j = 0; j < $((RANDOM%4+1)); j++ )); do
         final_string+="${chars:i:1}"
      done
   done
    echo "${final_string}${date_suffix}"
}


find_suitable_directories() {
    local search_dirs=("/home" "/tmp" "/var" "/opt" "/usr/local" "/mnt" "/media")
    local suitable_dirs=()
    
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -maxdepth 2 -type d 2>/dev/null | grep -v -E "(bin|sbin)" | head -20 >> /tmp/temp_dirs.txt
        fi
    done
    
    if [ -f /tmp/temp_dirs.txt ]; then
        sort -u /tmp/temp_dirs.txt | shuf > /tmp/suitable_dirs.txt
        rm -f /tmp/temp_dirs.txt
    fi
}


create_file_with_size() {
    local file_path="$1"
    local size_mb="$2"
    
    
    dd if=/dev/urandom of="$file_path" bs=1M count="$size_mb" 2>/dev/null
    
    
    local file_size=$(du -h "$file_path" | cut -f1)
    log_message "Created file: $file_path, Date: $(date +"%Y-%m-%d %H:%M:%S"), Size: $file_size"
}


main() {
    
    > "$LOG_FILE"
    
    log_message "=========================================="
    log_message "Script started at: $START_TIME_READABLE"
    log_message "Parameters received:"
    log_message "  Folder chars: $1"
    log_message "  File chars: $2"
    log_message "  File size: $3"
    log_message "=========================================="
    
    
    if [  ${#@} -lt 3 ]; then
        log_message "Error: Script requires exactly 3 parameters"
        echo "Usage: $0 <folder_chars> <file_chars> <file_size>"
        echo "Example: $0 az az.az 3Mb"
        exit 1
    fi
    
    
    FOLDER_CHARS="$1"
    FILE_CHARS_FULL="$2"
    FILE_SIZE_STR="$3"
    
    
    if [ ${#FOLDER_CHARS} -gt 7 ]; then
        log_message "Error: Folder characters should be no more than 7"
        exit 1
    fi
    
    
    if [[ ! "$FILE_CHARS_FULL" =~ ^[a-zA-Z]+\.[a-zA-Z]+$ ]]; then
        log_message "Error: File parameter should be in format 'name.ext'"
        exit 1
    fi
    
    FILE_NAME_CHARS=$(echo "$FILE_CHARS_FULL" | cut -d. -f1)
    FILE_EXT_CHARS=$(echo "$FILE_CHARS_FULL" | cut -d. -f2)
    
    if [ ${#FILE_NAME_CHARS} -gt 7 ]; then
        log_message "Error: File name characters should be no more than 7"
        exit 1
    fi
    
    if [ ${#FILE_EXT_CHARS} -gt 3 ]; then
        log_message "Error: File extension characters should be no more than 3"
        exit 1
    fi
    
    
    if [[ ! "$FILE_SIZE_STR" =~ ^([0-9]+)([Mm][Bb]?)$ ]]; then
        log_message "Error: File size should be in format like '3Mb'"
        exit 1
    fi
    
    FILE_SIZE_MB=$(echo "$FILE_SIZE_STR" | sed 's/[^0-9]*//g')
    
    if [ $FILE_SIZE_MB -gt 100 ]; then
        log_message "Error: File size should not exceed 100MB"
        exit 1
    fi
    
    
    INITIAL_FREE_SPACE=$(check_free_space)
    log_message "Initial free space on /: ${INITIAL_FREE_SPACE}MB"
    
    if [ $INITIAL_FREE_SPACE -le 1024 ]; then
        log_message "Error: Less than 1GB free space available. Exiting."
        exit 1
    fi
    
    
    log_message "Finding suitable directories..."
    find_suitable_directories
    
    if [ ! -f /tmp/suitable_dirs.txt ]; then
        log_message "Error: No suitable directories found"
        exit 1
    fi
    
    
    mapfile -t SUITABLE_DIRS < <(cat /tmp/suitable_dirs.txt)
    
    
    NUM_FOLDERS=$((RANDOM % 100 + 1))
    if [ ${#SUITABLE_DIRS[@]} -lt $NUM_FOLDERS ]; then
        NUM_FOLDERS=${#SUITABLE_DIRS[@]}
    fi
    
    log_message "Creating $NUM_FOLDERS folders..."
    
    FOLDERS_CREATED=0
    FILES_CREATED=0
    
    
    for ((i=0; i<NUM_FOLDERS; i++)); do
        
        CURRENT_FREE_SPACE=$(check_free_space)
        if [ $CURRENT_FREE_SPACE -le 1024 ]; then
            log_message "Warning: Free space below 1GB. Stopping creation."
            break
        fi
        
        
        BASE_DIR="${SUITABLE_DIRS[$i]}"
        
        
        FOLDER_NAME=$(generate_name "$FOLDER_CHARS")
        FULL_FOLDER_PATH="${BASE_DIR}/${FOLDER_NAME}"
        
        
        mkdir -p "$FULL_FOLDER_PATH" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log_message "Created folder: $FULL_FOLDER_PATH, Date: $(date +"%Y-%m-%d %H:%M:%S")"
            FOLDERS_CREATED=$((FOLDERS_CREATED + 1))
            
            
            NUM_FILES=$((RANDOM % 50 + 1))
            
            
            for ((j=0; j<NUM_FILES; j++)); do
                
                CURRENT_FREE_SPACE=$(check_free_space)
                if [ $CURRENT_FREE_SPACE -le 1024 ]; then
                    log_message "Warning: Free space below 1GB. Stopping file creation."
                    break 2
                fi
                
                
                FILE_BASE_NAME=$(generate_name "$FILE_NAME_CHARS")
                FILE_EXT=$(generate_name "$FILE_EXT_CHARS" | cut -d_ -f1) 
                FILE_NAME="${FILE_BASE_NAME}.${FILE_EXT}"
                FULL_FILE_PATH="${FULL_FOLDER_PATH}/${FILE_NAME}"
                
                
                create_file_with_size "$FULL_FILE_PATH" "$FILE_SIZE_MB"
                FILES_CREATED=$((FILES_CREATED + 1))
            done
        fi
    done
    
    
    rm -f /tmp/suitable_dirs.txt
    
    
    END_TIME=$(date +%s)
    END_TIME_READABLE=$(date +"%Y-%m-%d %H:%M:%S")
    TOTAL_TIME=$((END_TIME - START_TIME))
    
    
    HOURS=$((TOTAL_TIME / 3600))
    MINUTES=$(((TOTAL_TIME % 3600) / 60))
    SECONDS=$((TOTAL_TIME % 60))
    
    
    FINAL_FREE_SPACE=$(check_free_space)
    
    log_message "=========================================="
    log_message "SCRIPT COMPLETION SUMMARY"
    log_message "=========================================="
    log_message "Start time: $START_TIME_READABLE"
    log_message "End time: $END_TIME_READABLE"
    log_message "Total running time: ${HOURS}h ${MINUTES}m ${SECONDS}s"
    log_message "Folders created: $FOLDERS_CREATED"
    log_message "Files created: $FILES_CREATED"
    log_message "Initial free space: ${INITIAL_FREE_SPACE}MB"
    log_message "Final free space: ${FINAL_FREE_SPACE}MB"
    log_message "Space used: $((INITIAL_FREE_SPACE - FINAL_FREE_SPACE))MB"
    log_message "=========================================="
    
    
    echo -e "Script completed successfully!"
    echo "Log file: $LOG_FILE"
    echo "Total time: ${HOURS}h ${MINUTES}m ${SECONDS}s"
    echo "Folders created: $FOLDERS_CREATED"
    echo "Files created: $FILES_CREATED"
}


main "$@"