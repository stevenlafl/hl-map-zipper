#!/bin/bash

# Define input and output directories
input_dir="/input"
maps_dir="$input_dir/maps"
output_dir="/output"
complete_dir="$output_dir/complete"
incomplete_dir="$output_dir/incomplete"

# Create directories for complete and incomplete maps
mkdir -p "$complete_dir"
mkdir -p "$incomplete_dir"

# Initialize an associative array to track unique missing assets
declare -A all_missing_assets

# Iterate over all .bsp files in the maps directory
for bsp_file in "$maps_dir"/*.bsp; do
    # Extract the base name of the .bsp file (without path and extension)
    map_name=$(basename "$bsp_file" .bsp)
    
    # Create a temporary directory to store files before zipping
    temp_dir=$(mktemp -d)
    
    # Path to the ZIP file that will be created
    zip_file="$output_dir/$map_name.zip"

    # Create file to store missing assets for this map
    missing_file="$temp_dir/missing.txt"
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
        dest_file="$temp_dir/$line"
        
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

    # Determine whether the map is complete or incomplete based on the missing assets
    if [ -s "$missing_file" ]; then
        target_dir="$incomplete_dir"
        final_zip_file="$incomplete_dir/$map_name.zip"
    else
        target_dir="$complete_dir"
        final_zip_file="$complete_dir/$map_name.zip"
    fi

    # Change into the temporary directory to create the ZIP file
    (cd "$temp_dir" && zip -r "$zip_file" . > /dev/null)
    mv "$zip_file" "$final_zip_file"
    echo "Resources zipped for $map_name to $final_zip_file"
    
    # Clean up the temporary directory
    rm -rf "$temp_dir"
done

# Output list of all unique missing assets
echo "Generating global missing assets report..."
output_missing_file="$output_dir/missing.txt"
: > "$output_missing_file" # Clear the file before use

# Sort the global missing assets and write to the file
for asset in "${!all_missing_assets[@]}"; do
    echo "$asset"
done | sort -u > "$output_missing_file"

echo "Done processing maps. Check missing.txt files for missing assets."