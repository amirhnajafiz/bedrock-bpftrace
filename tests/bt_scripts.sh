#!/usr/bin/env sh
# file: tests/bt_scripts.sh

set -eu

BASE_DIR="bpftrace"

echo "[INFO] Starting recursive bpftrace dry-run tests"
echo "[INFO] Base directory: ${BASE_DIR}"

# Ensure base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "[ERROR] Base directory '${BASE_DIR}' does not exist"
    exit 1
fi

# Find all .bt files recursively
# Using find to traverse all children until no directories remain
find "$BASE_DIR" -type f -name "*.bt" | while read -r script_path; do
    echo "[INFO] Testing: ${script_path}"

    # Run bpftrace dry-run (-dd)
    # Capture stderr only, suppress stdout
    err_output=$(bpftrace -dd "$script_path" 2>&1 >/dev/null) || {
        echo "[ERROR] Dry-run failed for: ${script_path}"
        echo "[ERROR] bpftrace error output:"
        echo "---------"
        echo "$err_output"
        echo "---------"
        exit 1
    }

done

echo "[INFO] All .bt scripts passed successfully."
