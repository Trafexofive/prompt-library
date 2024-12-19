#!/bin/bash

# Configuration
MODEL="wizardlm2:7b"
DATA_DIR=".data"
TEMP_DIR="${DATA_DIR}/.temp"
OUTPUT_FILE="${DATA_DIR}/output.md"
CONTEXT_FILE="${DATA_DIR}/context.xml"
PROMPT_FILE="prompt.txt"
TEMP_INPUT="${TEMP_DIR}/temp_input.txt"
LOG_FILE="${DATA_DIR}/model_run.log"

# Function to log messages with timestamps
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check if required files exist
check_files() {
    local missing_files=0
    
    for file in "$CONTEXT_FILE" "$PROMPT_FILE"; do
        if [ ! -f "$file" ]; then
            log_message "ERROR: Required file not found: $file"
            missing_files=1
        fi
    done
    
    return $missing_files
}

# Function to ensure directories exist
setup_directories() {
    for dir in "$DATA_DIR" "$TEMP_DIR"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_message "Created directory: $dir"
        fi
    done
}

# Function to check if Ollama is installed and running
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        log_message "ERROR: Ollama is not installed"
        return 1
    fi
    
    # Basic check if Ollama service is responding
    if ! ollama list &> /dev/null; then
        log_message "ERROR: Ollama service is not running"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    # Initialize logging
    setup_directories
    log_message "Starting model run with $MODEL"
    
    # Perform checks
    check_ollama || exit 1
    check_files || exit 1
    
    # Clean up any existing temporary files
    [ -f "$TEMP_INPUT" ] && rm "$TEMP_INPUT"
    
    # Combine context and prompt
    if ! cat "$CONTEXT_FILE" "$PROMPT_FILE" > "$TEMP_INPUT"; then
        log_message "ERROR: Failed to combine input files"
        exit 1
    fi
    
    # Run the model
    log_message "Running model inference..."
    if ollama run "$MODEL" < "$TEMP_INPUT" > "$OUTPUT_FILE" 2>> "$LOG_FILE"; then
        log_message "Successfully generated output to: $OUTPUT_FILE"
        log_message "Output size: $(wc -l < "$OUTPUT_FILE") lines"
    else
        log_message "ERROR: Model execution failed"
        exit 1
    fi
    
    # Clean up
    rm "$TEMP_INPUT"
    log_message "Finished processing"
}

# Trap for cleanup on script exit
trap 'rm -f "$TEMP_INPUT"; log_message "Script terminated"' EXIT

# Execute main function
main
