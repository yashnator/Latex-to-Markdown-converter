#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: ./run.sh <input_file> <output_file>"
    exit 1
fi

# Assign arguments to variables
input_file=$1
output_file=$2

# Run make clean and make
make clean
make

# Check if main.out was generated successfully
if [ ! -f "./main.out" ]; then
    echo "Error: main.out was not generated. Please check your Makefile."
    exit 1
fi

# Run the executable with the provided arguments
./main.out < "$input_file" "$output_file"

# Provide a success message
echo "Execution complete. Output saved to $output_file."
