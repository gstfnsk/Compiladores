#!/bin/bash

# --- Configuration ---
# The executable to run
EXECUTABLE="./etapa4"

# The directory containing test subfolders
TEST_DIR="Testes"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# --- End Configuration ---


# 1. Check if the executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo "Error: Executable '$EXECUTABLE' not found."
    echo "Please make sure you have compiled your program."
    echo "You might need to run 'make'."
    exit 1
fi

# 2. Check if the Testes directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "Error: Test directory '$TEST_DIR' not found."
    exit 1
fi

echo "Starting all tests with '$EXECUTABLE'..."
echo ""

# 3. Loop through all .txt files in the specified subdirectories
for test_file in "$TEST_DIR"/ERR_*/*.txt "$TEST_DIR"/sem_erro/*.txt; do
    
    # Check if the file actually exists
    if [ -f "$test_file" ]; then
        echo "============================================================"
        echo "Running test: $test_file"
        echo "============================================================"
        
        # 1. Capture the entire output from the command
        output=$("$EXECUTABLE" < "$test_file")
        
        # 2. Get just the last line of the captured output
        last_line=$(echo "$output" | tail -n 1)
        
        # 3. Check if the test file is in the 'sem_erro' directory
        if [[ "$test_file" == *"sem_erro"* ]]; then
            # --- LOGIC FOR 'sem_erro' FOLDER ---
            # Logic is reversed: an error starting with "-->" is a FAILURE.
            
            if [[ "$last_line" == "--> "* ]]; then
                # This is a FAILURE case
                echo -e "${RED}Test FAILED${NC}"
                echo "$output" # Show the unexpected error
            else
                # This is a SUCCESS case
                echo -e "${GREEN}Test PASSED${NC}"
            fi

        else
            # --- LOGIC FOR ALL OTHER 'ERR_*' FOLDERS ---
            # Logic is normal: an error starting with "-->" is a SUCCESS.
            
            if [[ "$last_line" == "--> "* ]]; then
                # This is a SUCCESS case
                # Print the entire output in green
                echo -e "${GREEN}${output}${NC}"
            else
                # This is a FAILURE case
                echo -e "${RED}Test FAILED${NC}"
            fi
        fi
        
        echo "" # Add a newline for cleaner separation
    else
        echo "Warning: No test files found for pattern '$test_file'"
    fi
done

echo "============================================================"
echo "All tests finished."