#!/bin/bash

# Read the entire input from stdin
input=$(cat)

# Extract all content between single quotes
# This captures the actual JSON content in Apex format
quoted_parts=$(echo "$input" | grep -oE "'[^']*'" | sed "s/^'//;s/'$//")

# Join lines into one, removing Apex-style '+' line breaks
json_joined=$(echo "$quoted_parts" | tr -d '\n')

# Add basic line breaks for readability
formatted_json=$(echo "$json_joined" | sed -E '
s/([{}[\],])/ \1 /g
s/ +/ /g
s/ ?([{}[\],]) ?/\1\n/g
')

# Function to URL-encode using pure shell
url_encode() {
    local string="$1"
    local encoded=""
    for ((i=0; i<${#string}; i++)); do
        char="${string:i:1}"
        case "$char" in
            [a-zA-Z0-9._~-]) encoded+="$char" ;;
            *) encoded+=$(printf '%%%02X' "'$char") ;;
        esac
    done
    echo "$encoded"
}

# Encode JSON for URL
encoded_json=$(url_encode "$formatted_json")

# Construct URL with data and auto-process flag
url="https://jsonformatter.curiousconcept.com/?data=$encoded_json&process=true&template=twospace"

# Output formatted JSON
echo "$formatted_json"
echo

# Prompt to open browser
read -rp "Open a browser to edit the JSON (y/n)? " answer
case "$answer" in
  [nN]|[nN][oO]) exit 0 ;;
  *) open "$url" 2>/dev/null || xdg-open "$url" ;;
esac
