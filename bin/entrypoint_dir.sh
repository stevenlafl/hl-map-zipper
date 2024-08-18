#!/bin/bash

# Define input and output directories
input_dir="/input"
maps_dir="$input_dir/maps"
output_dir="/output"

# Initialize an associative array to track unique missing assets
declare -A all_missing_assets

# Iterate over all .bsp files in the maps directory
for bsp_file in "$maps_dir"/*.bsp; do
    # Extract the base name of the .bsp file (without path and extension)
    map_name=$(basename "$bsp_file" .bsp)
    
    # Create output directory for the map resources
    output_map_dir="$output_dir/$map_name"
    mkdir -p "$output_map_dir"
    
    # Create file to store missing assets for this map
    missing_file="$output_map_dir/missing.txt"
    : > "$missing_file" # Clear the file before use

    # Run resgen and clean the output
    resources=$(resgen "$bsp_file" -g -b /root/exclude.rfa | /usr/local/bin/clean.sh)
    
    # Process each resource line
    while IFS= read -r line; do
        # Trim leading and trailing whitespace using sed
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        # Skip if the line is empty
        [ -z "$line" ] && continue

        # Determine the source file and destination path
        src_file="$input_dir/$line"
        dest_file="$output_map_dir/$line"
        
        # Create the destination directory if it doesn't exist
        dest_dir=$(dirname "$dest_file")
        mkdir -p "$dest_dir"
        
        # Copy the resource file to the appropriate location
        if [ -f "$src_file" ]; then
            cp "$src_file" "$dest_file"
        else
            echo "Warning: Resource file $src_file does not exist."
            echo "$line" >> "$missing_file"
            all_missing_assets["$line"]=1
        fi
    done <<< "$resources"
    
    # Sort the missing assets for the current map
    sort -u "$missing_file" -o "$missing_file"

    echo "Resources copied for $map_name to $output_map_dir"
done

# Output list of all unique missing assets
echo "Generating global missing assets report..."
output_missing_file="$output_dir/missing.txt"
: > "$output_missing_file" # Clear the file before use

# Sort the global missing assets and write to the file
for asset in "${!all_missing_assets[@]}"; do
    echo "$asset"
done | sort -u > "$output_missing_file"

echo "Done copying resources for all maps. Check missing.txt files for missing assets."