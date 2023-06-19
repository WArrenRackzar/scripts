#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Please provide a file name as an argument."
  exit 1
fi

# Assign the first argument to the variable 'filename'
filename="$1"

# Check if the file exists
if [ -e "$filename" ]; then
  echo "File exists."
else
  echo "File not found."
fi
