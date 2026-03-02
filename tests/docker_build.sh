#!/usr/bin/env sh
# file: tests/docker_build.sh

echo "[INFO] Building Docker image for bpftrace tests"
docker build -f build/Dockerfile . -t bedrock-bpftrace:test

echo "[INFO] Running bpftrace tests in Docker container"
docker run \
    --rm \
    --ulimit memlock=-1:-1 \
    --privileged \
    --pid=host \
    -v /sys:/sys \
    -v /lib/modules:/lib/modules:ro \
    bedrock-bpftrace:test

echo "[INFO] Running specific bpftrace script test in Docker container"
docker run \
    --rm \
    --ulimit memlock=-1:-1 \
    --privileged \
    --pid=host \
    -v /sys:/sys \
    -v /lib/modules:/lib/modules:ro \
    bedrock-bpftrace:test \
    bpftrace -c "ls" bpftrace/execute/vfs_trace.bt

echo "[OK] Cleaning up Docker image"
docker rmi bedrock-bpftrace:test

echo "[SUCCESS] Docker tests completed successfully"
