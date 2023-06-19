#!/bin/bash

input_file="your_input_file.txt"

common_words=("the" "and" "in" "is" "it" "of" "on" "to" "a" "an")

word_count=$(grep -oE '\w+' "$input_file" | tr '[:upper:]' '[:lower:]' | awk '
  BEGIN { PROCINFO["sorted_in"] = "@val_num_desc" }
  {
    if (!($0 in common_words)) {
      count[tolower($0)]++
    }
  }
  END {
    for (word in count) {
      print word, count[word]
    }
  }
')

echo "$word_count"
