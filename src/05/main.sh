#!/bin/bash

start_time=$(date +%s.%N)

target_dir="$1"

if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

total_folders=$(find "$target_dir" -type d | wc -l)
echo "Total number of folders (including all nested ones) = $total_folders"

echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
du -h "$target_dir" | sort -rh | head -6 | tail -5 | awk '{print NR " - " $2 ", " $1}' | while IFS= read -r line; do
    echo "$line"
done
total_files=$(find "$target_dir" -type f | wc -l)
echo "Total number of files = $total_files"

echo "Number of:"

conf_files=$(find "$target_dir" -type f -name "*.conf" | wc -l)
echo "Configuration files (with the .conf extension) = $conf_files"

text_files=$(find "$target_dir" -type f -exec file {} \; | grep -i "text" | wc -l)
echo "Text files = $text_files"

exec_files=$(find "$target_dir" -type f -executable | wc -l)
echo "Executable files = $exec_files"

log_files=$(find "$target_dir" -type f -name "*.log" | wc -l)
echo "Log files (with the extension .log) = $log_files"

archive_files=$(find "$target_dir" -type f \( -name "*.zip" -o -name "*.tar" -o -name "*.gz" -o -name "*.bz2" -o -name "*.7z" -o -name "*.rar" \) | wc -l)
echo "Archive files = $archive_files"

symlinks=$(find "$target_dir" -type l | wc -l)
echo "Symbolic links = $symlinks"

echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"

temp_file=$(mktemp)

find "$target_dir" -type f -exec ls -lh {} + | awk 'NR>1 {
    size=$5
    path=$9
    for(i=10;i<=NF;i++) path=path" "$i
    split(path, arr, ".")
    ext=tolower(arr[length(arr)])
    if (ext ~ /conf/) type="conf"
    else if (ext ~ /log/) type="log"
    else if (ext ~ /(exe|sh|bash|run)/) type="exe"
    else if (ext ~ /(zip|tar|gz|bz2|7z|rar)/) type="archive"
    else type="other"
    print size " " path " " type
}' | sort -hr -k1 | head -10 | awk '{
    printf "%d - %s, %s, %s\n", NR, $2, $1, $3
}' | while IFS= read -r line; do
    echo "$line"
done

echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"

find "$target_dir" -type f -executable -exec ls -lh {} + | awk 'NR>1 {
    size=$5
    path=$9
    for(i=10;i<=NF;i++) path=path" "$i
    print size " " path
}' | sort -hr -k1 | head -10 | while IFS= read -r line; do
    size=$(echo "$line" | awk '{print $1}')
    filepath=$(echo "$line" | cut -d' ' -f2-)
    
    if [ -f "$filepath" ]; then
        if command -v md5sum &> /dev/null; then
            hash=$(md5sum "$filepath" | awk '{print $1}')
        elif command -v md5 &> /dev/null; then
            hash=$(md5 -q "$filepath")
        else
            hash="N/A"
        fi
        
        echo "$size - $filepath, $hash"
    fi
done | awk '{
    printf "%d - %s, %s\n", NR, $3, $1
}' | sed 's/, /, /g' | while IFS= read -r line; do
    hash=$(echo "$line" | grep -o '[a-f0-9]\{32\}' | head -1)
    if [ ! -z "$hash" ]; then
        echo "$line" | sed "s/, [a-f0-9]\{32\}/, $hash/"
    else
        echo "$line"
    fi
done

rm -f "$temp_file"

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Script execution time (in seconds) = $execution_time"