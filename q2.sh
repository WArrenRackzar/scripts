#!/bin/bash

# Get the filename from the command line.
filename=$1

# Create a list of common English words to exclude.
stop_words="the and in of to a is that it for on with as at by but from or about"

# Read the file and split the words into an array.
words=$(cat $filename | tr -s ' ' '\n' | sort | uniq)

# Exclude the common English words from the array.
for word in $words; do
  if [[ $stop_words =~ $word ]]; then
    words=$(echo $words | grep -v "$word")
  fi
done

# Count the number of occurrences of each word in the array.
word_counts=$(echo $words | awk '{count[$1]++} END {for (word in count) {print word, count[word]}}')

# Sort the word counts in descending order.
word_counts=$(echo $word_counts | sort -nr)

# Print the word counts.
for word, count in $word_counts; do
  echo "$word: $count"
done
