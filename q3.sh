#!/bin/bash

dir=$1
highest_average=0
highest_file=""

# Function to calculate average number of words per line
calculate_average() {
    local total_words=0
    local total_lines=0

    while IFS= read -r line; do
        ((total_words += $(echo "$line" | wc -w)))
        ((total_lines++))
    done < "$1"

    if [[ $total_lines -gt 0 ]]; then
        echo "Average words per line in $1: $((total_words / total_lines))"
        if [[ $((total_words / total_lines)) -gt $highest_average ]]; then
            highest_average=$((total_words / total_lines))
            highest_file="$1"
        fi
    else
        echo "No lines found in $1"
    fi
}

# Recursively find all .txt files and calculate average for each
find_txt_files() {
    local current_dir=$1

    for file in "$current_dir"/*; do
        if [[ -d "$file" ]]; then
            find_txt_files "$file"
        elif [[ -f "$file" && "${file##*.}" == "txt" ]]; then
            calculate_average "$file"
        fi
    done
}

# Call the function to start the search
find_txt_files "$dir"

# Display the file with the highest average word count
echo "File with the highest average word count: $highest_file"
echo "Highest average word count: $highest_average"
