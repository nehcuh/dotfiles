#!/bin/sh
# POSIX-compatible wrapper for install-unified.sh
# This script ensures the main installer runs with bash

# Check if bash is available
if ! command -v bash >/dev/null 2>&1; then
    echo "Error: This script requires bash, but bash is not available."
    echo "Please install bash first."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Run the main installer with bash
exec bash "$SCRIPT_DIR/install-unified.sh" "$@"