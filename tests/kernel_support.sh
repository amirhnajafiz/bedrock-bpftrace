#!/usr/bin/env sh
# file: tests/kernel_support.sh

set -e

echo "[INFO] Kernel: $(uname -r)"

# Check bpf() syscall availability
if ! grep -q bpf /proc/kallsyms 2>/dev/null; then
    echo "[ERROR] Kernel does not expose bpf syscall"
    exit 1
fi

# Check tracefs
if [ ! -d /sys/kernel/tracing ] && [ ! -d /sys/kernel/debug/tracing ]; then
    echo "[ERROR] tracefs not mounted"
    exit 1
fi

# Check BTF (recommended)
if [ -f /sys/kernel/btf/vmlinux ]; then
    echo "[OK] BTF detected"
else
    echo "[WARN] No BTF found — struct tracing may fail"
fi

# Check privileges (must load trivial program)
if ! bpftrace -e 'BEGIN { exit(); }' >/dev/null 2>&1; then
    echo "[ERROR] Cannot load BPF program (missing --privileged or CAP_BPF/CAP_SYS_ADMIN)"
    exit 1
fi

echo "[SUCCESS] Host is capable of running bpftrace scripts"
