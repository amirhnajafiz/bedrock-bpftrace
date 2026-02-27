#!/usr/bin/env sh
# file: tests/bt_scripts.sh

set -eu

BASE_DIR="${1:-bpftrace}"

echo "[INFO] Starting recursive bpftrace dry-run tests"
echo "[INFO] Base directory: ${BASE_DIR}"

# Ensure base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "[ERROR] Base directory '${BASE_DIR}' does not exist"
    exit 1
fi

# Dry-run mode (older versions of bpftrace may use -dd, newer versions use --dry-run)
DDRY_RUN_MODE=""
[ "$(bpftrace --help | grep -E -- '--dry-run|-dd')" ] && DDRY_RUN_MODE="--dry-run" || DDRY_RUN_MODE="-dd"

[ -DDRY_RUN_MODE ] || {
    echo "[ERROR] bpftrace does not support dry-run mode on this system"
    exit 1
}

find "$BASE_DIR" -type f -name "*.bt" | while read -r script_path; do
    echo "[INFO] Testing: ${script_path}"

    parent_dir="$(dirname "$script_path")"

    if [ -x "$parent_dir" ]; then
        err_output=$(bpftrace "$DDRY_RUN_MODE" -c "ls" "$script_path" 2>&1 >/dev/null) || {
            echo "[ERROR] Dry-run failed for: ${script_path}"
            echo "[ERROR] bpftrace error output:"
            echo "---------"
            echo "$err_output"
            echo "---------"
            exit 1
        }
    else
        err_output=$(bpftrace "$DDRY_RUN_MODE" "$script_path" 2>&1 >/dev/null) || {
            echo "[ERROR] Dry-run failed for: ${script_path}"
            echo "[ERROR] bpftrace error output:"
            echo "---------"
            echo "$err_output"
            echo "---------"
            exit 1
        }
    fi

done

echo "[INFO] All .bt scripts passed successfully."
