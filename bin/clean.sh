#!/bin/bash

# Load the exclude list into a pattern file
exclude_file="/root/exclude.rfa"

# Initialize a flag to mark the section of interest
in_section=false

# Read from stdin and process line by line
while IFS= read -r line; do
    # Check for the start marker
    if [[ "$line" =~ ^Creating\ .res\ file\ .* ]]; then
        in_section=true
    elif [[ "$line" =~ ^Failed\ to\ open\ .*\.res\ for\ writing\.$ ]] || [[ "$line" =~ ^Done\ creating\ res\ file\(s\)! ]] || [[ "$line" =~ ^Failed\ to\ create\ res\ file\(s\)\ for:\.* ]]; then
        # Check for the end markers and reset the flag
        in_section=false
    elif $in_section; then
        # Exclude lines that have "Resource is excluded:" or match specific error patterns
        if [[ "$line" != *"Resource is excluded:"* ]] && \
           [[ "$line" != *"No resources were found for"* ]] && \
           [[ "$line" != *"Error parsing"* ]] && \
           [[ "$line" != *"Failed to create res file(s) for:"* ]]; then
            # Trim leading and trailing whitespace using sed
            trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

            # Check if the line matches any entry in exclude.rfa
            if ! grep -qFx "$trimmed_line" "$exclude_file"; then
                # Print the line if it doesn't match any entry in exclude.rfa
                echo "$trimmed_line"
            fi
        fi
    fi
done