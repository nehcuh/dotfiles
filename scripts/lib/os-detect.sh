#!/bin/bash
# OS detection
# Returns: OS variable set to "linux" or "macos"

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        log_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

export OS="$(detect_os)"
