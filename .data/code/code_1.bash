#!/bin/bash

CONTEXT_FILE=".data/context.xml"
JSON_OUTPUT=".data/context/context.json"

# Use xml2json to convert the XML to a JSON format
xmllint --noout $CONTEXT_FILE | xml2json - > temp.txt

# Convert the temporary file from xml2json's format to a standard JSON format using jq
jq '.' temp.txt > $JSON_OUTPUT

# Clean up the temporary file
rm temp.txt

