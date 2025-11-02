#!/bin/bash

# --- Configuration ---
# The executable to run
EXECUTABLE="./etapa4"

# The directory containing test subfolders
TEST_DIR="Testes"
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
#    This globbing pattern (Testes/ERR_*/*.txt) ensures we only look
#    inside subfolders starting with ERR_ and the 'sem_erro' folder.
#    It automatically skips the files you listed in the 'Testes/' root.
for test_file in "$TEST_DIR"/ERR_*/*.txt "$TEST_DIR"/sem_erro/*.txt; do
    
    # Check if the file actually exists (handles cases where a glob might find no files)
    if [ -f "$test_file" ]; then
        echo "============================================================"
        echo "Running test: $test_file"
        echo "============================================================"
        
        # Run the executable and redirect the test file as standard input
        "$EXECUTABLE" < "$test_file"
        
        echo "" # Add a newline for cleaner separation
    else
        echo "Warning: No test files found for pattern '$test_file'"
    fi
done

echo "============================================================"
echo "All tests finished."