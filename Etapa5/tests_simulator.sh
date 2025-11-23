#!/bin/bash

# --- Configuration ---
EXECUTABLE="./etapa5"
SIMULATOR="python3 ilocsim.py"
TEST_DIR="Testes/Iloc"
OUTPUT_DIR="Testes/My_iloc_output"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Counters ---
total_tests=0
passed_tests=0
failed_tests=0
skipped_tests=0

# --- Setup ---
if [ ! -f "$EXECUTABLE" ]; then
    echo -e "${RED}Error: Executable '$EXECUTABLE' not found.${NC}"
    exit 1
fi

if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}Error: Test directory '$TEST_DIR' not found.${NC}"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${BLUE}Creating output directory '$OUTPUT_DIR'...${NC}"
    mkdir -p "$OUTPUT_DIR"
fi

echo "Starting Simulation Comparison Tests..."
echo "------------------------------------------------------------"

# --- Main Loop ---
for test_file in "$TEST_DIR"/*; do
    
    # Ignore the .iloc files in the source folder
    if [[ "$test_file" == *.iloc ]]; then
        continue
    fi

    if [ -f "$test_file" ]; then
        ((total_tests++))
        test_name=$(basename "$test_file")
        
        # Define file paths
        reference_iloc="${test_file}.iloc"
        my_iloc="${OUTPUT_DIR}/${test_name}.iloc"
        
        reference_sim_out="${OUTPUT_DIR}/${test_name}_ref_sim.txt"
        my_sim_out="${OUTPUT_DIR}/${test_name}_my_sim.txt"

        echo -n "Test $test_name: "

        # Check if reference ILOC exists
        if [ ! -f "$reference_iloc" ]; then
            echo -e "${YELLOW}SKIPPED (Reference .iloc not found)${NC}"
            ((skipped_tests++))
            continue
        fi

        # Clean up previous output files to ensure "creation" checks are valid
        rm -f "$reference_sim_out" "$my_sim_out"

        # STEP 1: Run your compiler
        # We allow it to run even if it errors, to produce whatever output (or empty)
        "$EXECUTABLE" < "$test_file" > "$my_iloc" 2>/dev/null
        
        # STEP 2: Run simulator on Reference ILOC
        # Only run if the iloc file exists and is not empty (to mimic your "not created" condition if input is bad)
        if [ -s "$reference_iloc" ]; then
             $SIMULATOR -m -x "$reference_iloc" > "$reference_sim_out" 2>&1
        fi

        # STEP 3: Run simulator on My ILOC output
        # Only run if my_iloc exists and is not empty
        if [ -s "$my_iloc" ]; then
             $SIMULATOR -m -x "$my_iloc" > "$my_sim_out" 2>&1
        fi

        # STEP 4: Compare results based on file existence
        
        # Check existence [ -f returns true if file exists ]
        if [ -f "$reference_sim_out" ]; then ref_exists=1; else ref_exists=0; fi
        if [ -f "$my_sim_out" ]; then my_exists=1; else my_exists=0; fi

        if [ $ref_exists -eq 0 ] && [ $my_exists -eq 0 ]; then
            # Both NOT created -> PASS
            echo -e "${GREEN}PASSED (Both outputs empty/not created)${NC}"
            ((passed_tests++))
        
        elif [ $ref_exists -ne $my_exists ]; then
            # One created, one not -> FAIL
            echo -e "${RED}FAILED${NC}"
            echo -e "  ${YELLOW}-> Mismatch: One simulator output was created, the other was not.${NC}"
            ((failed_tests++))
            
        else
            # Both created -> Compare content using diff
            if diff -q "$reference_sim_out" "$my_sim_out" >/dev/null; then
                echo -e "${GREEN}PASSED${NC}"
                ((passed_tests++))
            else
                echo -e "${RED}FAILED${NC}"
                echo -e "  ${YELLOW}-> Simulation content differs. See ${OUTPUT_DIR}/${test_name}_*.txt${NC}"
                ((failed_tests++))
            fi
        fi
    fi
done

echo "------------------------------------------------------------"
echo "Simulation Test Summary"
echo "------------------------------------------------------------"
echo -e "Total tests: ${total_tests}"
echo -e "  - ${GREEN}Passed:  ${passed_tests}${NC}"
echo -e "  - ${RED}Failed:  ${failed_tests}${NC}"
echo -e "  - ${YELLOW}Skipped: ${skipped_tests}${NC}"
echo "------------------------------------------------------------"