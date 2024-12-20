#!/bin/bash

# Define the output file
OUTPUT_FILE="./.data/context.xml"
IGNOREFILE="./.context.ignore"

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
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$OUTPUT_FILE"
    echo "<context>" >> "$OUTPUT_FILE"
}

# Read exclusions from .context.ignore
load_exclusions() {
    EXCLUSIONS=()
    if [[ -f $IGNOREFILE ]]; then
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
            EXCLUSIONS+=("-not -path './$line'")
        done < .context.ignore
    fi
}

# Add file content to the XML structure
add_file_content_to_xml() {
    local file="$1"
    
    # Append the file name as a header
    echo "  <file name=\"$(basename "$file")\">" >> "$OUTPUT_FILE"
    
    # Append the content of the file in CDATA section
    echo "    <![CDATA[" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "    ]]>" >> "$OUTPUT_FILE"
    
    echo "  </file>" >> "$OUTPUT_FILE"
}

process_files() {
    # Find files excluding patterns from .context.ignore
    eval find . -type f ${EXCLUSIONS[@]} -print0 | while IFS= read -r -d '' file; do
        add_file_content_to_xml "$file"
    done
}

# Add the file structure to the XML (include all files and directories in .data, excluding hidden ones and those matching .context.ignore)
add_file_structure_to_xml() {
    echo "  <file-structure>" >> "$OUTPUT_FILE"
    eval find . -type f ${EXCLUSIONS[@]} | sort | sed 's/^/    /' >> "$OUTPUT_FILE"
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
    load_exclusions
    process_files
    add_file_structure_to_xml
    close_xml_structure
}

# Run the script
main
