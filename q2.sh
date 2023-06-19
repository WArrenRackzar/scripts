#!/bin/bash

excluded_words=("the" "and" "in")

while IFS= read -r word; do
  word=$(echo "$word" | tr '[:upper:]' '[:lower:]')

  if [[ ! " ${excluded_words[@]} " =~ " $word " ]] && [[ $word =~ ^[[:alpha:]]+$ ]]; then
    word_counts[$word]=$((word_counts[$word]+1))
  fi
done < "$1"

sorted_words=()
for word in "${!word_counts[@]}"; do
  sorted_words+=("$word ${word_counts[$word]}")
done
sorted_words=($(printf "%s\n" "${sorted_words[@]}" | sort -k2 -nr))

for entry in "${sorted_words[@]}"; do
  echo "$entry"
done
