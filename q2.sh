#!/bin/bash

# Define the common English words to exclude
excluded_words=("the" "and" "in")

# Read the file and count the occurrences of each unique word
while IFS= read -r word; do
  # Convert the word to lowercase
  word=$(echo "$word" | tr '[:upper:]' '[:lower:]')

  # Exclude common English words and words with non-alphabetic characters
  if [[ ! " ${excluded_words[@]} " =~ " $word " ]] && [[ $word =~ ^[[:alpha:]]+$ ]]; then
    # Increment the count of the word
    word_counts[$word]=$((word_counts[$word]+1))
  fi
done < "$1"

# Sort the word counts in descending order of frequency
sorted_words=()
for word in "${!word_counts[@]}"; do
  sorted_words+=("$word ${word_counts[$word]}")
done
sorted_words=($(printf "%s\n" "${sorted_words[@]}" | sort -k2 -nr))

# Display the word count in descending order of frequency
for entry in "${sorted_words[@]}"; do
  echo "$entry"
done
