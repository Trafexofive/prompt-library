#!/bin/bash

# Define the output file
OUTPUT_FILE=".data/context.txt"

# Create the .data directory if it doesn't exist
mkdir -p .data

# Erase old context
> "$OUTPUT_FILE"

# Iterate through all branches (files and subdirectories) in the CWD
for file in $(find . -type f); do
    # Append the file name as a header
    echo "\n===== $file =====" >> "$OUTPUT_FILE"
    # Append the content of the file
    cat "$file" >> "$OUTPUT_FILE"
    echo >> "$OUTPUT_FILE"  # Add a newline for separation
done

# Append the file structure using the tree command
echo "\n===== FILE STRUCTURE =====" >> "$OUTPUT_FILE"
tree . >> "$OUTPUT_FILE"
