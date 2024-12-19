#!/bin/bash


MODEL="wizardlm2:7b"
FILENAME=".data/output.md"
CONTEXT_FILE=".data/context.xml"
PROMPT_FILE="prompt.txt"
TEMP_FILE=".data/.temp/temp_input.txt" # Temporary file to combine context and prompt

rm $TEMP_FILE

# Combine context and prompt into a temporary file
cat $CONTEXT_FILE $PROMPT_FILE > $TEMP_FILE

# Command to run the model
CMD="ollama run $MODEL < $TEMP_FILE > $FILENAME"

# Execute the command
eval $CMD

