#!/bin/bash
# Define the output file
OUTPUT_FILE="./.data/context.xml"

# Create the .data directory if it doesn't exist
create_output_directory() {
mkdir -p "$(dirname "$OUTPUT_FILE")"
}

# Erase old context
erase_old_context() {
    > "$OUTPUT_FILE"
}

# Start the XML structure
start_xml_structure() {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$OUTPUT_FILE"
    echo "<context>" >> "$OUTPUT_FILE"
}

# Add file content to the XML structure
add_file_content_to_xml() {
    local file="$1"
    
    # Skip the output file itself
    if [ "$file" = "$OUTPUT_FILE" ]; then
        return
    fi
    
    # Append the file name as a header
    echo "  <file name=\"$(basename "$file")\">" >> "$OUTPUT_FILE"
    
    # Append the content of the file
    echo "    <![CDATA[" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "    ]]]>" >> "$OUTPUT_FILE"
    
    echo "  </file>" >> "$OUTPUT_FILE"
}

# Process files and add them to the XML
process_files() {
    find . -type f \
        ! -path './.git*' \
        ! -path './.scripts/context.sh' \
        ! -name "$(basename "$OUTPUT_FILE")" \
        ! -path "./node_modules/*" \
        -print0 | while IFS= read -r -d '' file; do
            add_file_content_to_xml "$file"
        done
}

# Add the file structure to the XML
add_file_structure_to_xml() {
    echo "  <file-structure>" >> "$OUTPUT_FILE"
    
    find . -type f -o -type d \
        ! -path './.git*' \
        ! -path './.scripts/*' \
        ! -path "./node_modules/*" \
        ! -name "$(basename "$OUTPUT_FILE")" \
        | sort | sed 's/^/    /' >> "$OUTPUT_FILE"
    
    echo "  </file-structure>" >> "$OUTPUT_FILE"
}

# Close the XML structure
close_xml_structure() {
    echo "</context>" >> "$OUTPUT_FILE"
}

# Main function to orchestrate the script
main() {
    create_output_directory
    erase_old_context
    start_xml_structure
    process_files
    add_file_structure_to_xml
    close_xml_structure
}

# Run the script
main
