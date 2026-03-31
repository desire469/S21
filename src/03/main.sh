#!/bin/bash

show_usage() {
    echo -e "Usage: $0 <mode>"
    echo -e "Modes:"
    echo -e "  1 - Delete by log file"
    echo -e "  2 - Delete by creation date and time (from log)"
    echo -e "  3 - Delete by name mask"
    echo -e ""
    echo -e "Note for mode 2:"
    echo -e "  Date/time refers to entries in the log file, not file system timestamps"
    exit 1
}

safe_remove() {
    local path="$1"
    local type="$2"
    
    if [ "$type" = "file" ] && [ -f "$path" ]; then
        rm -f "$path"
        if [ $? -eq 0 ]; then
            echo -e "Deleted file: $path"
            return 0
        else
            echo -e "Failed to delete file: $path"
            return 1
        fi
    elif [ "$type" = "dir" ] && [ -d "$path" ]; then
        if [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
            rmdir "$path" 2>/dev/null
        else
            rm -rf "$path" 2>/dev/null
        fi
        if [ $? -eq 0 ]; then
            echo -e "Deleted directory: $path"
            return 0
        else
            echo -e "Failed to delete directory: $path"
            return 1
        fi
    else
        echo -e "Not found: $path"
        return 2
    fi
}

get_entries_from_log_by_date() {
    local log_file="$1"
    local start_date="$2"
    local end_date="$3"
    local -n files_ref="$4"
    local -n dirs_ref="$5"
    
    start_epoch=$(date -d "$start_date" +%s 2>/dev/null)
    end_epoch=$(date -d "$end_date" +%s 2>/dev/null)
    
    if [ -z "$start_epoch" ] || [ -z "$end_epoch" ]; then
        return 1
    fi
    
    while IFS= read -r line; do
        clean_line=$(echo "$line" | sed -r "s/\x1B\[[0-9;]*[mK]//g")
        
        if [[ "$clean_line" =~ Date:\ ([0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            entry_date="${BASH_REMATCH[1]}"
            entry_epoch=$(date -d "$entry_date" +%s 2>/dev/null)
            
            if [ -n "$entry_epoch" ] && [ "$entry_epoch" -ge "$start_epoch" ] && [ "$entry_epoch" -le "$end_epoch" ]; then
                if [[ "$clean_line" == Created\ folder:* ]]; then
                    path=$(echo "$clean_line" | sed -n 's/.*Created folder: \(.*\), Date:.*/\1/p' | xargs)
                    if [ -n "$path" ]; then
                        dirs_ref+=("$path")
                    fi
                elif [[ "$clean_line" == Created\ file:* ]]; then
                    path=$(echo "$clean_line" | sed -n 's/.*Created file: \(.*\), Date:.*/\1/p' | xargs)
                    if [ -n "$path" ]; then
                        files_ref+=("$path")
                    fi
                fi
            fi
        fi
    done < "$log_file"
    
    return 0
}

delete_by_date() {
    echo -e "=== Delete by Creation Date and Time (from log) ==="
    
    LOG_DIR="../02/"
    if [ ! -d "$LOG_DIR" ]; then
        echo -e "Log directory not found: $LOG_DIR"
        exit 1
    fi
    
    echo -e "Available log files:"
    local log_files=($(ls -1t "$LOG_DIR"/filesystem_creation_*.log 2>/dev/null))
    
    if [ ${#log_files[@]} -eq 0 ]; then
        echo -e "No log files found in $LOG_DIR"
        exit 1
    fi
    
    for i in "${!log_files[@]}"; do
        echo -e "  $((i+1))) $(basename "${log_files[$i]}")"
    done
    
    echo -e "\nEnter the number of the log file to use:"
    read -p "Selection: " selection
    
    local selected_log=""
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -le ${#log_files[@]} ] && [ "$selection" -ge 1 ]; then
        selected_log="${log_files[$((selection-1))]}"
        echo -e "Using: $(basename "$selected_log")"
    else
        echo -e "Invalid selection"
        exit 1
    fi
    
    echo -e "\nEnter start date and time (format: YYYY-MM-DD HH:MM:SS)"
    echo -e "Example: 2026-01-13 08:36:00"
    read -p "Start: " start_date
    
    if [[ ! "$start_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        echo -e "Invalid format. Use: YYYY-MM-DD HH:MM:SS"
        exit 1
    fi
    
    echo -e "\nEnter end date and time (format: YYYY-MM-DD HH:MM:SS)"
    echo -e "Example: 2026-01-13 08:37:00"
    read -p "End: " end_date
    
    if [[ ! "$end_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        echo -e "Invalid format. Use: YYYY-MM-DD HH:MM:SS"
        exit 1
    fi
    
    start_timestamp=$(date -d "$start_date" +%s 2>/dev/null)
    end_timestamp=$(date -d "$end_date" +%s 2>/dev/null)
    
    if [ -z "$start_timestamp" ] || [ -z "$end_timestamp" ]; then
        echo -e "Invalid date/time values"
        exit 1
    fi
    
    if [ "$start_timestamp" -gt "$end_timestamp" ]; then
        echo -e "Start date must be before end date"
        exit 1
    fi
    
    echo -e "\nSearching for entries in log file..."
    
    local files_to_delete=()
    local dirs_to_delete=()
    
    if ! get_entries_from_log_by_date "$selected_log" "$start_date" "$end_date" files_to_delete dirs_to_delete; then
        echo -e "Failed to parse log file"
        exit 1
    fi
    
    echo -e "Found ${#files_to_delete[@]} files and ${#dirs_to_delete[@]} directories created in the specified time range"
    
    if [ ${#files_to_delete[@]} -eq 0 ] && [ ${#dirs_to_delete[@]} -eq 0 ]; then
        echo -e "No entries found in the specified time range"
        exit 0
    fi
    
    echo -e "\n=== Preview of items to delete ==="
    if [ ${#dirs_to_delete[@]} -gt 0 ]; then
        echo -e "Directories:"
        for dir in "${dirs_to_delete[@]:0:5}"; do
            echo -e "  $dir"
        done
        if [ ${#dirs_to_delete[@]} -gt 5 ]; then
            echo -e "  ... and $(( ${#dirs_to_delete[@]} - 5 )) more"
        fi
    fi
    
    if [ ${#files_to_delete[@]} -gt 0 ]; then
        echo -e "\nFiles:"
        for file in "${files_to_delete[@]:0:5}"; do
            echo -e "  $file"
        done
        if [ ${#files_to_delete[@]} -gt 5 ]; then
            echo -e "  ... and $(( ${#files_to_delete[@]} - 5 )) more"
        fi
    fi
    
    echo -e "\nWARNING: This will delete all files and folders created between:"
    echo -e "  Start: $start_date"
    echo -e "  End:   $end_date"
    echo -e "Total items: $(( ${#files_to_delete[@]} + ${#dirs_to_delete[@]} ))"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "Cancelled by user"
        exit 0
    fi
    
    echo -e "\nStarting deletion..."
    
    local total_deleted=0
    local total_failed=0
    
    for file in "${files_to_delete[@]}"; do
        if safe_remove "$file" "file"; then
            total_deleted=$((total_deleted + 1))
        else
            total_failed=$((total_failed + 1))
        fi
    done
    
    if [ ${#dirs_to_delete[@]} -gt 0 ]; then
        IFS=$'\n' sorted_dirs=($(printf "%s\n" "${dirs_to_delete[@]}" | awk -F/ '{print NF, $0}' | sort -rn | cut -d' ' -f2-))
        unset IFS
        
        for dir in "${sorted_dirs[@]}"; do
            if safe_remove "$dir" "dir"; then
                total_deleted=$((total_deleted + 1))
            else
                total_failed=$((total_failed + 1))
            fi
        done
    fi
    
    echo -e "\n=== Summary ==="
    echo -e "Time range: $start_date to $end_date"
    echo -e "Log file: $(basename "$selected_log")"
    echo -e "Successfully deleted: $total_deleted"
    echo -e "Failed to delete: $total_failed"
}

delete_by_log() {
    echo -e "=== Delete by Log File (ALL entries) ==="
    
    LOG_DIR="../02/"
    if [ ! -d "$LOG_DIR" ]; then
        echo -e "Log directory not found: $LOG_DIR"
        exit 1
    fi
    
    echo -e "Available log files:"
    local log_files=($(ls -1t "$LOG_DIR"/filesystem_creation_*.log 2>/dev/null))
    
    if [ ${#log_files[@]} -eq 0 ]; then
        echo -e "No log files found in $LOG_DIR"
        exit 1
    fi
    
    for i in "${!log_files[@]}"; do
        echo -e "  $((i+1))) $(basename "${log_files[$i]}")"
    done
    
    echo -e "\nEnter the number of the log file to use (or 0 to use all):"
    read -p "Selection: " selection
    
    local selected_logs=()
    if [ "$selection" = "0" ]; then
        selected_logs=("${log_files[@]}")
        echo -e "Using all log files"
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -le ${#log_files[@]} ]; then
        selected_logs=("${log_files[$((selection-1))]}")
        echo -e "Using: $(basename "${selected_logs[0]}")"
    else
        echo -e "Invalid selection"
        exit 1
    fi
    
    local total_items=0
    for log_file in "${selected_logs[@]}"; do
        file_count=$(grep -c "Created file:" "$log_file")
        dir_count=$(grep -c "Created folder:" "$log_file")
        total_items=$((total_items + file_count + dir_count))
    done
    
    if [ $total_items -eq 0 ]; then
        echo -e "No items found in selected log file(s)"
        exit 0
    fi
    
    echo -e "\nWARNING: This will delete ALL ${total_items} files and folders listed in the selected log file(s)."
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "Cancelled by user"
        exit 0
    fi
    
    local total_deleted=0
    local total_failed=0
    
    for log_file in "${selected_logs[@]}"; do
        echo -e "\nProcessing: $(basename "$log_file")"
        
        local paths_to_delete=()
        
        while IFS= read -r line; do
            clean_line=$(echo "$line" | sed -r "s/\x1B\[[0-9;]*[mK]//g")
            
            if [[ "$clean_line" == Created\ folder:* ]]; then
                path=$(echo "$clean_line" | sed -n 's/.*Created folder: \(.*\), Date:.*/\1/p' | xargs)
                if [ -n "$path" ]; then
                    paths_to_delete+=("$path")
                fi
            elif [[ "$clean_line" == Created\ file:* ]]; then
                path=$(echo "$clean_line" | sed -n 's/.*Created file: \(.*\), Date:.*/\1/p' | xargs)
                if [ -n "$path" ]; then
                    paths_to_delete+=("$path")
                fi
            fi
        done < "$log_file"
        
        local files=()
        local dirs=()
        
        for path in "${paths_to_delete[@]}"; do
            if [ -f "$path" ]; then
                files+=("$path")
            elif [ -d "$path" ]; then
                dirs+=("$path")
            fi
        done
        
        echo -e "Found ${#files[@]} files and ${#dirs[@]} directories to delete"
        
        for file in "${files[@]}"; do
            if safe_remove "$file" "file"; then
                total_deleted=$((total_deleted + 1))
            else
                total_failed=$((total_failed + 1))
            fi
        done
        
        if [ ${#dirs[@]} -gt 0 ]; then
            IFS=$'\n' sorted_dirs=($(printf "%s\n" "${dirs[@]}" | awk -F/ '{print NF, $0}' | sort -rn | cut -d' ' -f2-))
            unset IFS
            
            for dir in "${sorted_dirs[@]}"; do
                if safe_remove "$dir" "dir"; then
                    total_deleted=$((total_deleted + 1))
                else
                    total_failed=$((total_failed + 1))
                fi
            done
        fi
    done
    
    echo -e "\n=== Summary ==="
    echo -e "Successfully deleted: $total_deleted"
    echo -e "Failed to delete: $total_failed"
}

delete_by_mask() {
    echo -e "=== Delete by Name Mask ==="
    
    echo -e "Enter name mask (e.g., 'az_130126' or 'az.*_130126'):"
    echo -e "Format: <characters>_<DDMMYY>"
    echo -e "For files: <characters>.<extension>_<DDMMYY>"
    read -p "Mask: " mask
    
    if [ -z "$mask" ]; then
        echo -e "Mask cannot be empty"
        exit 1
    fi
    
    echo -e "\nWARNING: This will delete all files and folders matching mask:"
    echo -e "  Mask pattern: *$mask*"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "Cancelled by user"
        exit 0
    fi
    
    echo -e "\nSearching for matches..."
    
    local total_deleted=0
    local total_failed=0
    
    search_dirs=("/home" "/tmp" "/var" "/opt" "/usr/local" "/mnt" "/media")
    
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r file; do
                [ -z "$file" ] && continue
                
                filename=$(basename "$file")
                if [[ "$filename" == *"$mask"* ]]; then
                    if safe_remove "$file" "file"; then
                        total_deleted=$((total_deleted + 1))
                    else
                        total_failed=$((total_failed + 1))
                    fi
                fi
            done < <(find "$dir" -type f -name "*${mask}*" 2>/dev/null)
        fi
    done
    
    local matching_dirs=()
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r directory; do
                [ -z "$directory" ] && continue
                dirname=$(basename "$directory")
                if [[ "$dirname" == *"$mask"* ]]; then
                    matching_dirs+=("$directory")
                fi
            done < <(find "$dir" -type d -name "*${mask}*" 2>/dev/null)
        fi
    done
    
    if [ ${#matching_dirs[@]} -gt 0 ]; then
        IFS=$'\n' sorted_dirs=($(printf "%s\n" "${matching_dirs[@]}" | awk -F/ '{print NF, $0}' | sort -rn | cut -d' ' -f2-))
        unset IFS
        
        for directory in "${sorted_dirs[@]}"; do
            if safe_remove "$directory" "dir"; then
                total_deleted=$((total_deleted + 1))
            else
                total_failed=$((total_failed + 1))
            fi
        done
    fi
    
    echo -e "\n=== Summary ==="
    echo -e "Mask used: $mask"
    echo -e "Successfully deleted: $total_deleted"
    echo -e "Failed to delete: $total_failed"
}

main() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "Warning: Not running as root. Some files may not be deletable."
    fi
    
    echo -e "========================================"
    echo -e "    System Cleanup Script - Part 3     "
    echo -e "========================================"
    echo
    if [ ${#@} -ne 1 ]; then
        echo -e "Error: Script requires exactly 1 parameter"
        show_usage
    fi
    
    MODE="$1"
    
    START_TIME=$(date +%s)
    
    case "$MODE" in
        1)
            delete_by_log
            ;;
        2)
            delete_by_date
            ;;
        3)
            delete_by_mask
            ;;
        *)
            echo -e "Error: Invalid mode. Must be 1, 2, or 3"
            show_usage
            ;;
    esac
    
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    
    echo -e "\n========================================"
    echo -e "Cleanup completed!"
    echo -e "Total time: ${TOTAL_TIME} seconds"
    echo -e "========================================"
}

main "$@"