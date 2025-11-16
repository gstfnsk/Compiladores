#!/bin/bash

# Define the name of the final combined file
OUTPUT_FILE="combined_output.txt"

# Get the full path of the directory where the script is running
# This helps make the folder/file paths in the output cleaner (e.g., ./ERR_DECLARED)
SCRIPT_DIR=$(pwd)

# Clear the output file at the start
> "$OUTPUT_FILE"

echo "Starting combination..."
echo "Output will be saved to $OUTPUT_FILE"

# Find all directories starting one level deep (ignores the current '.')
# We sort them to ensure a consistent order
for dir in $(find . -mindepth 1 -type d | sort); do
    
    # --- Check if the directory contains any .txt files ---
    # We do this check first so we don't print a folder header for an empty folder.
    # 'find ... -print -quit' finds the first match and stops.
    # 'read' will be successful (exit code 0) if 'find' provides any output.
    if find "$dir" -maxdepth 1 -type f -name "*.txt" -print -quit | read -r; then
        
        echo "Processing directory: $dir"
        
        # Add the folder header to the output file
        echo "==================================================" >> "$OUTPUT_FILE"
        echo "FOLDER: $dir" >> "$OUTPUT_FILE"
        echo "==================================================" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE" # Add a blank line for spacing

        # --- Now, loop through all .txt files in this directory ---
        # We use 'find' again, sorted, and pipe to 'while read'
        # This properly handles filenames that might have spaces.
        find "$dir" -maxdepth 1 -type f -name "*.txt" | sort | while IFS= read -r file; do
            
            echo "  -> Adding file: $file"
            
            # Add the file header
            echo "----------------------------------------" >> "$OUTPUT_FILE"
            echo "FILE: $file" >> "$OUTPUT_FILE"
            echo "----------------------------------------" >> "$OUTPUT_FILE"
            
            # Add the file content
            cat "$file" >> "$OUTPUT_FILE"
            
            # Add two newlines for separation after the content
            echo -e "\n" >> "$OUTPUT_FILE"
        done
    fi
done

echo "Combination complete."
