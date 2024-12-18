#!/bin/bash

MODEL="wizardlm2:7b"

FILENAME="newfile.md"

# Check if an argument is passed
if [ -z "$1" ]; then
  echo "Usage: ./run.sh 'your_prompt_here'"
  exit 1
fi

PROMPT="$1"
CMD="ollama run $MODEL \"$PROMPT\" > $FILENAME"

# Execute the command
eval $CMD

