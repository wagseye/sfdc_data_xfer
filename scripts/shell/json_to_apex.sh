#!/bin/bash

# Read JSON input from stdin until EOF (Ctrl+D)
json_input=$(cat)

# Escape backslashes only
escaped_json=$(echo "$json_input" | sed 's/\\/\\\\/g')

# Split into lines, strip only the first level of indentation (e.g., 2 spaces)
stripped_lines=$(echo "$escaped_json" | sed 's/^  //')

# Extract the first and last line for custom handling
first_line=$(echo "$stripped_lines" | head -n 1)
last_line=$(echo "$stripped_lines" | tail -n 1)

# Start the Apex string with opening line
echo "String jsonStr = '$first_line' +"

# Middle lines (excluding first and last)
echo "$stripped_lines" | sed '1d;$d' | while IFS= read -r line; do
    echo "'$line' +"
done

# Final line with closing semicolon
echo "'$last_line';"
