#!/bin/bash

# Check if a filename is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

FILE=$1

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# Read file content
CONTENT=$(cat "$FILE")

# Extract variables in the format ${VAR}
VARIABLES=$(echo "$CONTENT" | grep -o '\${[^}]*}' | tr -d '${}')

# Check if all variables are set
for VAR in $VARIABLES; do
    if [ -z "${!VAR}" ]; then
        echo "Error: The variable $VAR must be set."
        exit 1
    fi
done

# Perform substitution while preserving newlines
EVALUATED_CONTENT=$(envsubst < "$FILE")

# Output the result
echo "$EVALUATED_CONTENT"
