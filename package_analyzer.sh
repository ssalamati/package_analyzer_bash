#!/bin/bash

# Default configuration
ARCHITECTURE=$1  # Take the first argument as the architecture
MIRROR_URL="http://ftp.uk.debian.org/debian/dists/stable/main/"
RETRY_COUNT=3
WAIT_SECONDS=5
TOP_N=10
QUIET_MODE=0

# Check if architecture is provided
if [ -z "$ARCHITECTURE" ]; then
    echo "Architecture is required."
    exit 1
fi

# Shift the arguments after parsing the architecture
shift

CONTENTS_FILE="contents-${ARCHITECTURE}.gz"

# Parse the remaining command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mirror-url) MIRROR_URL="$2"; shift ;;
        -r|--retry-count) RETRY_COUNT="$2"; shift ;;
        -w|--wait-seconds) WAIT_SECONDS="$2"; shift ;;
        -n|--top-n) TOP_N="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Function to download the Contents file with retry logic
download_file() {
    local url=$1
    local target_file=$2
    local attempts=0

    while [ $attempts -lt $RETRY_COUNT ]; do
        if wget -O "$target_file" "$url"; then
            echo "Download successful."
            return 0
        else
            echo "Download failed. Retrying..."
            sleep $WAIT_SECONDS
            ((attempts++))
        fi
    done

    echo "Failed to download file after $RETRY_COUNT attempts."
    return 1
}

# Cleanup function to remove the downloaded file
cleanup() {
    echo "Cleaning up..."
    rm -f "$CONTENTS_FILE"
}

# Trap to ensure cleanup runs on exit or interrupt
trap cleanup EXIT INT TERM

# Function to download and parse the file
main() {
    local url="${MIRROR_URL}Contents-${ARCHITECTURE}.gz"

    download_file "$url" "$CONTENTS_FILE"
    if [ $? -ne 0 ]; then
        echo "Error downloading the Contents file."
        exit 1
    fi

    # Parse the Contents file and print statistics
    gunzip -c "$CONTENTS_FILE" | awk -F ',' '{for (i = 1; i <= NF; i++) print $i}' | awk '{print $NF}' | sort | uniq -c | sort -nr | head -n $TOP_N
}

main
