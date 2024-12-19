#!/bin/bash

# Configuration
DATA_DIR=".data"
INPUT_FILE="${DATA_DIR}/output.md"
CODE_DIR="${DATA_DIR}/code"
LOG_FILE="${DATA_DIR}/extract.log"

# Function to log messages with timestamps
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to ensure directories exist
setup_directories() {
    for dir in "$DATA_DIR" "$CODE_DIR"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_message "Created directory: $dir"
        fi
    done
}

# Main execution
main() {
    # Setup and checks
    setup_directories
    
    if [ ! -f "$INPUT_FILE" ]; then
        log_message "ERROR: Input file not found: $INPUT_FILE"
        exit 1
    fi
    
    # Clean previous extractions
    rm -f "${CODE_DIR}"/*
    log_message "Cleaned previous extractions"
    
    # Extract code blocks using awk
    log_message "Starting code extraction from $INPUT_FILE"
    
    awk '
    BEGIN {
        block_num = 0
        in_block = 0
        current_content = ""
    }
    
    # Detect start of code block
    /^```/ {
        if (!in_block) {
            block_num++
            in_block = 1
            # Get language (remove ```), default to txt if none specified
            lang = substr($0, 4)
            gsub(/[[:space:]]+/, "", lang)
            if (lang == "") lang = "txt"
            # Create filename
            filename = "./'"$CODE_DIR"'/code_" block_num "." lang
            next
        } else {
            # End of block
            in_block = 0
            print current_content > filename
            current_content = ""
            next
        }
    }
    
    # Collect content when inside a code block
    {
        if (in_block) {
            current_content = current_content $0 "\n"
        }
    }
    
    END {
        print block_num  # Print total number of blocks
    }
    ' "$INPUT_FILE" > "${CODE_DIR}/.block_count"
    
    # Get the number of extracted blocks
    TOTAL_BLOCKS=$(cat "${CODE_DIR}/.block_count")
    rm "${CODE_DIR}/.block_count"
    
    if [ "$TOTAL_BLOCKS" -gt 0 ]; then
        log_message "Successfully extracted $TOTAL_BLOCKS code blocks"
        
        # Create index file
        {
            echo "# Extracted Code Blocks"
            echo "Extracted on: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "Total blocks: $TOTAL_BLOCKS"
            echo
            echo "## Files"
            for i in $(seq 1 "$TOTAL_BLOCKS"); do
                file=$(ls "${CODE_DIR}/code_${i}."* 2>/dev/null)
                if [ -n "$file" ]; then
                    filename=$(basename "$file")
                    echo "- [$filename]($filename)"
                fi
            done
        } > "${CODE_DIR}/index.md"
        
        log_message "Created index file at ${CODE_DIR}/index.md"
    else
        log_message "No code blocks found in input file"
        # Show file info for debugging
        log_message "Input file size: $(wc -c < "$INPUT_FILE") bytes"
        log_message "Input file lines: $(wc -l < "$INPUT_FILE") lines"
        log_message "First few lines of input file:"
        head -n 5 "$INPUT_FILE" | while IFS= read -r line; do
            log_message "LINE: $line"
        done
    fi
}

# Trap for unexpected exits
trap 'log_message "Script terminated"' EXIT

# Execute main function
main
