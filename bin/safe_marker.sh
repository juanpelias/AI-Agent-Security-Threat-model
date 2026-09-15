#!/bin/bash
set -euo pipefail

# Check for exactly one argument matching the exact string "course-marker"
if [ "$#" -ne 1 ] || [ "$1" != "course-marker" ]; then
    echo "Error: Invalid argument. Usage: $0 course-marker" >&2
    exit 1
fi

# Define fixed path safely without executing user input
TARGET_DIR="$HOME/csce465-agentsec/hw1/markers"
TARGET_FILE="$TARGET_DIR/marker.txt"

# Create the marker file safely
mkdir -p "$TARGET_DIR"
touch "$TARGET_FILE"
echo "Marker successfully created at $TARGET_FILE"
