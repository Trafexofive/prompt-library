
#!/bin/bash

# Define input/output files
CONTEXT_FILE="./.data/context.xml"
PROMPT_FILE="./prompt.txt"
OUTPUT_FILE="./.data/context-attached-prompt.xml"

# Check if the context and prompt files exist
if [[ ! -f "$CONTEXT_FILE" ]]; then
    echo "Error: Context file ($CONTEXT_FILE) not found!"
    exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: Prompt file ($PROMPT_FILE) not found!"
    exit 1
fi

# Start the new XML structure
start_xml_structure() {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$OUTPUT_FILE"
    echo "<context>" >> "$OUTPUT_FILE"
}

# Add the content of the prompt file
add_prompt_to_xml() {
    echo "  <prompt>" >> "$OUTPUT_FILE"
    echo "    <![CDATA[" >> "$OUTPUT_FILE"
    cat "$PROMPT_FILE" >> "$OUTPUT_FILE"
    echo "    ]]]>" >> "$OUTPUT_FILE"
    echo "  </prompt>" >> "$OUTPUT_FILE"
}

# Add the content from the original context.xml
add_context_to_xml() {
    # Skip the XML declaration and root element
    tail -n +2 "$CONTEXT_FILE" | head -n -1 >> "$OUTPUT_FILE"
}

# Close the new XML structure
close_xml_structure() {
    echo "</context>" >> "$OUTPUT_FILE"
}

# Main function to orchestrate the script
main() {
    start_xml_structure
    add_context_to_xml
    add_prompt_to_xml
    close_xml_structure
}

# Run the script
main
