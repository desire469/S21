#!/bin/bash

LOG_FILE="log_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}
log_message "Starting script with parameters: $@"

if [ "$#" -ne 6 ]; then
    log_message "ERROR: Script requires exactly 6 parameters"
    echo "Usage: $0 <absolute_path> <num_folders> <folder_letters> <num_files> <file_letters> <size_kb>"
    exit 1
fi

if [ -z "$1" ]; then
    log_message "ERROR: Absolute path cannot be empty"
    exit 1
fi

if ! [[ "$1" =~ ^/ ]]; then
    log_message "ERROR: Path must be absolute (start with /)"
    exit 1
fi

if ! [ -d "$1" ]; then
    log_message "ERROR: Directory '$1' does not exist"
    exit 1
fi

if ! [ -w "$1" ]; then
    log_message "ERROR: No write permission for directory '$1'"
    exit 1
fi

if ! [[ "$2" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: Number of folders must be a positive integer"
    exit 1
fi

if [ "$2" -lt 1 ]; then
    log_message "ERROR: Number of folders must be at least 1"
    exit 1
fi

if [ -z "$3" ]; then
    log_message "ERROR: Folder letters cannot be empty"
    exit 1
fi

if [ ${#3} -gt 7 ]; then
    log_message "ERROR: Folder letters cannot exceed 7 characters"
    exit 1
fi

if ! [[ "$3" =~ ^[a-zA-Z]+$ ]]; then
    log_message "ERROR: Folder letters must contain only English alphabet characters"
    exit 1
fi

if ! [[ "$4" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: Number of files must be a positive integer"
    exit 1
fi

if [ "$4" -lt 1 ]; then
    log_message "ERROR: Number of files must be at least 1"
    exit 1
fi

if [ -z "$5" ]; then
    log_message "ERROR: File letters cannot be empty"
    exit 1
fi

if [[ ! "$5" =~ ^[a-zA-Z]+\.[a-zA-Z]+$ ]]; then
    log_message "ERROR: File letters must be in format 'name.extension' (e.g., 'file.txt')"
    exit 1
fi

first_part=$(echo "$5" | awk -F '.' '{print $1}')
second_part=$(echo "$5" | awk -F '.' '{print $2}')

if [ ${#first_part} -gt 7 ]; then
    log_message "ERROR: File name part cannot exceed 7 characters"
    exit 1
fi

if [ ${#second_part} -gt 3 ]; then
    log_message "ERROR: File extension cannot exceed 3 characters"
    exit 1
fi

if ! [[ "$first_part" =~ ^[a-zA-Z]+$ ]]; then
    log_message "ERROR: File name must contain only English alphabet characters"
    exit 1
fi

if ! [[ "$second_part" =~ ^[a-zA-Z]+$ ]]; then
    log_message "ERROR: File extension must contain only English alphabet characters"
    exit 1
fi

size_param="$6"

if [ -z "$size_param" ]; then
    log_message "ERROR: File size cannot be empty"
    exit 1
fi

size_kb=$(echo "$size_param" | sed -E 's/[kK][bB]?$//')

if ! [[ "$size_kb" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: File size must be a number (with optional 'kb' or 'k')"
    log_message "Valid examples: 10, 10k, 10kb, 10K, 10KB"
    exit 1
fi

if [ "$size_kb" -gt 100 ]; then
    log_message "ERROR: File size cannot exceed 100 kilobytes"
    exit 1
fi

if [ "$size_kb" -le 0 ]; then
    log_message "ERROR: File size must be greater than 0"
    exit 1
fi

available_space_kb=$(df -k "$1" | tail -1 | awk '{print $4}')
if [ "$available_space_kb" -lt 1048576 ]; then
    log_message "ERROR: Less than 1GB of free space available on filesystem"
    exit 1
fi

total_files=$(( $2 * $4 ))
estimated_space_needed=$(( total_files * size_kb * 1024 ))
if [ "$estimated_space_needed" -gt "$available_space_kb" ]; then
    log_message "ERROR: Not enough disk space for all files"
    log_message "Required: $((estimated_space_needed / 1024 / 1024))MB, Available: $((available_space_kb / 1024 / 1024))MB"
    exit 1
fi

log_message "Parameters validated successfully"
log_message "Target directory: $1"
log_message "Number of folders to create: $2"
log_message "Folder letters: $3"
log_message "Files per folder: $4"
log_message "File pattern: $5"
log_message "File size: ${size_kb}KB"
log_message "Available space: $((available_space_kb / 1024 / 1024))MB"
log_message "Log file: $LOG_FILE"



created_folders=0
log_message "Starting folder creation..."

for (( o = 0; o < $2; o++ )); do
   final_string=""
   for (( i = 0; i < ${#3}; i++ )); do
      if (( i == ${#3}-1 )); then
         if [ ${#final_string} -lt 4 ]; then
            for (( j = 0; j < 4-${#final_string}; j++ )); do
               final_string+="${3:i:1}"
            done
         fi
      fi
      for (( j = 0; j < $((RANDOM%4+1)); j++ )); do
         final_string+="${3:i:1}"
      done
   done
   current_date=$(date +"%d%m%y")
   final_string+="_$current_date"
   
   if [ ${#final_string} -gt 255 ]; then
       log_message "Warning: Generated folder name too long, truncating"
       final_string="${final_string:0:255}"
   fi
   
   folder_path="$1/$final_string"
   creation_date=$(date '+%Y-%m-%d %H:%M:%S')
   
   mkdir -p "$folder_path"
   if [ $? -ne 0 ]; then
       log_message "ERROR: Failed to create directory '$folder_path'"
       exit 1
   fi
   
   log_message "Created folder: $folder_path"
   
   ((created_folders++))
done

log_message "Folder creation completed: $created_folders folders created"

created_files=0
log_message "Starting file creation..."

for folder in "$1"/*/; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        log_message "Processing folder: $folder_name"
        
        for (( o = 0; o < $4; o++ )); do
            final_string=""
            for (( i = 0; i < ${#first_part}; i++ )); do
                if (( i == ${#first_part}-1 )); then
                    if [ ${#final_string} -lt 4 ]; then
                        for (( j = 0; j < 4-${#final_string}; j++ )); do
                            final_string+="${first_part:i:1}"
                        done
                    fi
                fi
                for (( j = 0; j < $((RANDOM%4+1)); j++ )); do
                    final_string+="${first_part:i:1}"
                done
            done
            
            extension=""
            for (( i = 0; i < ${#second_part}; i++ )); do
                if (( i == ${#second_part}-1 )); then
                    if [ ${#extension} -lt 3 ]; then
                        for (( j = 0; j < 3-${#extension}; j++ )); do
                            extension+="${second_part:i:1}"
                        done
                    fi
                fi
                for (( j = 0; j < $((RANDOM%4+1)); j++ )); do
                    extension+="${second_part:i:1}"
                done
            done

            current_date=$(date +"%d%m%y")
            filename="${final_string}_${current_date}.${extension}"
            
            if [ ${#filename} -gt 255 ]; then
                log_message "Warning: Generated filename too long, truncating"
                filename="${filename:0:255}"
            fi
            
            filepath="$folder/$filename"
            creation_date=$(date '+%Y-%m-%d %H:%M:%S')
            
            touch "$filepath"
            if [ $? -ne 0 ]; then
                log_message "ERROR: Failed to create file '$filepath'"
                continue
            fi
            
            if command -v truncate ; then
                truncate -s "${size_kb}K" "$filepath"
            elif command -v dd ; then
                dd if=/dev/zero of="$filepath" bs=1024 count="$size_kb" status=none
            else
                log_message "ERROR: Neither truncate nor dd command found"
                exit 1
            fi
            
            if [ $? -eq 0 ]; then
                actual_size=$(stat -c%s "$filepath" || ls -l "$filepath" | awk '{print $5}')
                actual_size_kb=$((actual_size / 1024))
                
                log_message "Created file: $filepath (${actual_size_kb}KB)"
                
                ((created_files++))
                
                current_space=$(df -k "$1" | tail -1 | awk '{print $4}')
                if [ "$current_space" -lt 1048576 ]; then
                    log_message "WARNING: Less than 1GB of free space remaining. Stopping."
                    break 2
                fi
            fi
        done
    fi
done

log_message "========================================"
log_message "Script completed successfully!"
log_message "Created:"
log_message "  - Folders: $created_folders"
log_message "  - Files: $created_files"
log_message "  - Total size: $((created_files * size_kb / 1024))MB ($((created_files * size_kb))KB)"
log_message "========================================"