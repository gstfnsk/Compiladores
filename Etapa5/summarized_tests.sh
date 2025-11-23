#!/bin/bash

# --- Configuration ---
# The executable to run
EXECUTABLE="./etapa5"

# The directory containing test subfolders
TEST_DIR="Testes"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# --- End Configuration ---

# --- Counters ---
total_tests=0
passed_tests=0
failed_tests=0
# --- End Counters ---


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
        ((total_tests++))
        echo "============================================================"
        echo "Running test: $test_file"
        echo "============================================================"
        
        # 1. Capture the entire output from the command
        output=$("$EXECUTABLE" < "$test_file")
        
        # 2. Check if the test file is in the 'sem_erro' directory
        if [[ "$test_file" == *"sem_erro"* ]]; then
            # --- LOGIC FOR 'sem_erro' FOLDER ---
            
            # Get just the last line
            last_line=$(echo "$output" | tail -n 1)
            
            # Logic is reversed: an error starting with "-->" is a FAILURE.
            if [[ "$last_line" == "--> "* ]]; then
                # This is a FAILURE case
                echo -e "${RED}Test FAILED${NC}"
                ((failed_tests++))
            else
                # This is a SUCCESS case
                echo -e "${GREEN}Test PASSED${NC}"
                ((passed_tests++))
            fi

        else
            # --- LOGIC FOR ALL OTHER 'ERR_*' FOLDERS ---

            # 1. Get the expected folder name (e.g., "ERR_UNDECLARED")
            expected_folder_name=$(basename "$(dirname "$test_file")")
            
            # 2. ***THIS IS THE FIX***
            #    Construct the expected *prefix* for the first line WITH brackets
            expected_prefix="[$expected_folder_name]"
            
            # 3. Get the first line of the output
            first_line=$(echo "$output" | head -n 1)
            
            # 4. Perform the check: "does the line *start with* [FOLDER_NAME]?"
            if [[ "$first_line" == "$expected_prefix"* ]]; then
                # This is a SUCCESS case
                echo -e "${GREEN}Test PASSED${NC}"
                ((passed_tests++))
            else
                # This is a FAILURE case
                echo -e "${RED}Test FAILED${NC}"
                ((failed_tests++))
            fi
        fi
        
        echo "" # Add a newline for cleaner separation
    else
        echo "Warning: No test files found for pattern '$test_file'"
    fi
done

echo "============================================================"
echo "Test Summary"
echo "============================================================"
echo -e "Total tests run: ${total_tests}"
echo -e "  - ${GREEN}Passed: ${passed_tests}${NC}"
echo -e "  - ${RED}Failed: ${failed_tests}${NC}"
echo "============================================================"