#!/bin/bash

COMMON_WORDS=("the" "and" "in")

filename=$1

if [ ! -f "$filename" ]; then
  echo "File '$filename' does not exist."
  exit 1
fi

declare -A word_count
while read -r line; do
  words=($line)

  for word in "${words[@]}"; do
    word=$(echo "$word" | tr '[:upper:]' '[:lower:]' | sed 's/[^[:alnum:]]//g')

    if [[ ! " ${COMMON_WORDS[*]} " =~ " ${word} " ]] && [[ -n $word ]]; then
      ((word_count[$word]++))
    fi
  done
done < "$filename"

sorted_words=()
for word in "${!word_count[@]}"; do
  sorted_words+=("$word:${word_count[$word]}")
done
sorted_words=($(echo "${sorted_words[@]}" | tr ' ' '\n' | sort -t':' -k2rn -k1 | tr '\n' ' '))

for word in "${sorted_words[@]}"; do
  echo "$word"
done
