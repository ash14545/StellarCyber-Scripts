#!/bin/bash

# Prompt user for two integers
read -p "Enter the first integer: " num1
read -p "Enter the second integer: " num2

# Perform addition
result=$((num1 + num2))

# Display the result
echo "The sum of $num1 and $num2 is: $result"
