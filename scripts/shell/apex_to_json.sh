#!/bin/bash

# Read Apex-style string from stdin
input=$(cat)

# Remove first and last lines
json_lines=$(echo "$input" | sed '1d;$d')

# Clean up each line
json_raw=$(echo "$json_lines" | sed "s/^'//; s/'[[:space:]]*+//")

# Join into single line
json_joined=$(echo "$json_raw" | tr -d '\n')

# Add basic line breaks for readability
json_pretty=$(echo "$json_joined" | sed -E '
s/([{}[\],])/ \1 /g
s/ +/ /g
s/ ?([{}[\],]) ?/\1\n/g
')

# Wrap in braces (in case Apex stripped them)
formatted_json="{ $json_pretty }"

# Function to URL-encode the JSON string (without jq)
url_encode() {
    local string="$1"
    local encoded=""
    for ((i=0; i<${#string}; i++)); do
        char="${string:i:1}"
        case "$char" in
            [a-zA-Z0-9._~-]) encoded+="$char" ;;  # Allow these characters as is
            *) encoded+=$(printf '%%%02X' "'$char") ;;  # URL encode other characters
        esac
    done
    echo "$encoded"
}

# URL encode the formatted JSON
encoded_json=$(url_encode "$formatted_json")

# Construct the URL with the data and process=true
url="https://jsonformatter.curiousconcept.com/?data=$encoded_json&process=true&template=twospace"

# Display the formatted JSON
echo "$formatted_json"
echo

# Prompt to open browser
read -rp "Open a browser to edit the JSON (y/n)? " answer

case "$answer" in
  [nN]|[nN][oO]) exit 0 ;;
  *) 
    # Open the JSON formatter with the encoded JSON
    open "$url" 2>/dev/null || xdg-open "$url"
    ;;
esac
