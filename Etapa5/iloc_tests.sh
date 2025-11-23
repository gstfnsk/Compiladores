#!/bin/bash

# --- Configuration ---
# The executable to run
EXECUTABLE="./etapa5"

# The directory containing ILOC tests
TEST_DIR="Testes/Iloc"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# --- End Configuration ---

# --- Counters ---
total_tests=0
passed_tests=0
failed_tests=0
skipped_tests=0
# --- End Counters ---

# 1. Check if the executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo -e "${RED}Error: Executable '$EXECUTABLE' not found.${NC}"
    echo "Please make sure you have compiled your program (e.g., by running 'make')."
    exit 1
fi

# 2. Check if the test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}Error: Test directory '$TEST_DIR' not found.${NC}"
    exit 1
fi

echo "Starting ILOC generation tests with '$EXECUTABLE'..."
echo ""

# 3. Loop through all files in the ILOC test directory
for test_file in "$TEST_DIR"/*; do
    
    # Ignore the .iloc files themselves
    if [[ "$test_file" == *.iloc ]]; then
        continue
    fi

    # Check if the item is a file
    if [ -f "$test_file" ]; then
        ((total_tests++))
        echo "============================================================"
        echo "Running test: $test_file"
        echo "============================================================"
        
        expected_file="${test_file}.iloc"

        # Check if the corresponding .iloc file exists
        if [ ! -f "$expected_file" ]; then
            echo -e "${YELLOW}Test SKIPPED: Expected output file '$expected_file' not found.${NC}"
            ((skipped_tests++))
        else
            # Run the compiler and compare its output with the expected file
            # 'diff -q' quietly compares files. It returns 0 if they are the same, non-zero otherwise.
            if diff -q <("$EXECUTABLE" < "$test_file") "$expected_file" >/dev/null; then
                echo -e "${GREEN}Test PASSED${NC}"
                ((passed_tests++))
            else
                echo -e "${RED}Test FAILED${NC}"
                ((failed_tests++))
            fi
        fi
        echo "" # Add a newline for cleaner separation
    fi
done

echo "============================================================"
echo "ILOC Test Summary"
echo "============================================================"
echo -e "Total tests run: ${total_tests}"
echo -e "  - ${GREEN}Passed: ${passed_tests}${NC}"
echo -e "  - ${RED}Failed: ${failed_tests}${NC}"
echo -e "  - ${YELLOW}Skipped: ${skipped_tests}${NC}"
echo "============================================================"
