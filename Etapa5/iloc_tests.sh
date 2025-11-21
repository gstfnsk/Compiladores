#!/bin/bash

# --- Configuration ---
# The compiler executable to run
EXECUTABLE="./etapa5"

# The ILOC simulator
SIMULATOR="./ilocsim.py"

# The directory containing the stage 5 tests
TEST_DIR="Testes/Iloc"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# --- End Configuration ---

# 1. Check if the compiler executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo -e "${RED}Error: Compiler '$EXECUTABLE' not found.${NC}"
    echo "Please make sure you have compiled your program (e.g., run 'make')."
    exit 1
fi

# 2. Check if the ILOC simulator exists
if [ ! -f "$SIMULATOR" ]; then
    echo -e "${RED}Error: Simulator '$SIMULATOR' not found.${NC}"
    exit 1
fi

# 3. Check if the Test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}Error: Test directory '$TEST_DIR' not found.${NC}"
    exit 1
fi

echo -e "${BLUE}Starting tests with '$EXECUTABLE' and '$SIMULATOR'...${NC}"
echo ""

# 4. Loop through all .txt files in the specified directory
for test_file in "$TEST_DIR"/*.txt; do
    if [ -f "$test_file" ]; then
        basename=$(basename "$test_file" .txt)
        iloc_file="$TEST_DIR/$basename.iloc"

        echo "============================================================"
        echo -e "Running test: ${YELLOW}$test_file${NC}"
        echo "============================================================"

        # Compile the test file to an .iloc file
        "$EXECUTABLE" < "$test_file" > "$iloc_file"
        echo "Generated ILOC code in: $iloc_file"

        # Run the simulator on the generated ILOC code
        echo -e "${GREEN}--- Simulator Output (Final Memory State) ---${NC}"
        "$SIMULATOR" --memory "$iloc_file"
        echo -e "${GREEN}-------------------------------------------${NC}"
        echo ""

        # Clean up the generated .iloc file
        rm "$iloc_file"
    fi
done

echo "============================================================"
echo -e "${BLUE}All tests finished.${NC}"