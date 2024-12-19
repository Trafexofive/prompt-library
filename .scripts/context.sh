#!/bin/bash

# Define the output file and the working directory
OUTPUT_FILE="../.data/context.xml"
PWD_DIR=".."

# Create the .data directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Erase old context
> "$OUTPUT_FILE"

# Start the XML structure
echo '<?xml version="1.0" encoding="UTF-8"?>' >> "$OUTPUT_FILE"
echo '<context>' >> "$OUTPUT_FILE"

# Iterate through all non-hidden files and subdirectories in the specified PWD_DIR
for file in $(find "$PWD_DIR" -type f ! -path "$PWD_DIR/.*" ! -name "prompt"); do
    # Append the file name as a header
    echo "  <file>" >> "$OUTPUT_FILE"
    echo "    <name>${file#$PWD_DIR/}</name>" >> "$OUTPUT_FILE" # Remove the PWD_DIR prefix
    echo "    <content><![CDATA[" >> "$OUTPUT_FILE"
    # Append the content of the file
    cat "$file" >> "$OUTPUT_FILE"
    echo "    ]]></content>" >> "$OUTPUT_FILE"
    echo "  </file>" >> "$OUTPUT_FILE"
done

# Append the file structure using the tree command
echo "  <file_structure>" >> "$OUTPUT_FILE"
tree -I '.*' "$PWD_DIR" | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g' >> "$OUTPUT_FILE" # Escape special XML characters
echo "  </file_structure>" >> "$OUTPUT_FILE"

# Close the XML structure
echo '</context>' >> "$OUTPUT_FILE"
