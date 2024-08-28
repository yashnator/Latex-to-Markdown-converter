#!/bin/bash

# Directory containing the test files
TEST_DIR="tests"
# The run script that takes input and output file arguments
RUN_SCRIPT="./run.sh"

results=""

# Loop over each .tex file in the tests directory
for test_file in "$TEST_DIR"/*.tex; do
    # Derive the base name (without extension) of the test file
    base_name=$(basename "$test_file" .tex)
    
    # Define the output file name
    output_file="${TEST_DIR}/${base_name}_out.md"
    
    # Define the expected output file name
    expected_file="${TEST_DIR}/${base_name}.md"
    
    # Run the build and the test
    echo "Running test for $test_file..."
    make all > /dev/null 2>&1
    
    # Run the run.sh script with the current test file and output file
    $RUN_SCRIPT "$test_file" "$output_file"
    
    # Compare the generated output with the expected output
    if diff "$output_file" "$expected_file"; then
        results+="Test $base_name passed!✅\n"
    else
        results+="Test $base_name failed!❌\n"
    fi
    
    # Clean up the generated output file
    rm -rf "$output_file"
done

echo -e "$results"