FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBBPF_VERSION=v1.5.0
ENV BPFTRACE_VERSION=v0.24.0

# Install dependencies
RUN apt-get update && apt-get install -y \
    git build-essential cmake flex bison \
    libelf-dev zlib1g-dev \
    libfl-dev libedit-dev \
    clang llvm \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Build and install libbpf
# -----------------------------
RUN git clone --branch ${LIBBPF_VERSION} --depth 1 https://github.com/libbpf/libbpf.git /tmp/libbpf && \
    cd /tmp/libbpf/src && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/libbpf

# Ensure pkg-config finds libbpf
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# -----------------------------
# Build and install bpftrace
# -----------------------------
RUN git clone --branch ${BPFTRACE_VERSION} --depth 1 https://github.com/bpftrace/bpftrace.git /tmp/bpftrace && \
    cd /tmp/bpftrace && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/bpftrace

WORKDIR /app
COPY tests/bt_scripts.sh .

# Default command
CMD ["./bt_scripts.sh"]
