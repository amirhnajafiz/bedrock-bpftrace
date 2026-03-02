# ============================
# Stage 1 — Builder (using Ubuntu 24.04)
# ============================
FROM ubuntu:24.04 AS builder

# Set environment variables for non-interactive installation and versions of dependencies
ENV DEBIAN_FRONTEND=noninteractive
ENV LIBBPF_VERSION=v1.5.0
ENV BPFTRACE_VERSION=v0.24.0

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    linux-tools-generic \
    libbpfcc-dev \
    bpfcc-tools \
    libcereal-dev \
    llvm-18 \
    llvm-18-dev \
    clang-18 \
    libclang-18-dev \
    pahole \
    libgtest-dev \
    libgmock-dev \
    libdw-dev \
    git \
    ca-certificates \
    make \
    g++ \
    kmod \
    wget \
    curl \
    apt-transport-https \
    gnupg \
    libseccomp2 \
    xz-utils \
    procps \
    build-essential \
    cmake \
    flex \
    bison \
    xxd \
    libelf-dev zlib1g-dev \
    libfl-dev libedit-dev \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build libbpf
# We need to build libbpf from source to ensure we have the latest version with all the necessary features for bpftrace.
# The version of libbpf available in the Ubuntu 24.04 (v1.3.0) is older than the version required by bpftrace (v1.5.0),
# which may cause compatibility issues.
RUN git clone --depth 1 --branch ${LIBBPF_VERSION} \
    https://github.com/libbpf/libbpf.git /tmp/libbpf && \
    make -C /tmp/libbpf/src -j$(nproc) && \
    make -C /tmp/libbpf/src install PREFIX=/usr LIBDIR=/usr/lib/x86_64-linux-gnu && \
    rm -rf /tmp/libbpf

# Build bpftrace
# We need to build bpftrace from source to ensure we have the latest version with all the necessary features and bug fixes.
RUN git clone --depth 1 --branch ${BPFTRACE_VERSION} \
    https://github.com/bpftrace/bpftrace.git /tmp/bpftrace && \
    cmake -S /tmp/bpftrace -B /tmp/bpftrace/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm \
        -DClang_DIR=/usr/lib/llvm-18/lib/cmake/clang && \
    cmake --build /tmp/bpftrace/build -j$(nproc) && \
    cmake --install /tmp/bpftrace/build && \
    strip /usr/local/bin/bpftrace && \
    rm -rf /tmp/bpftrace


# ============================
# Stage 2 — Runtime (using Ubuntu 24.04)
# ============================
FROM ubuntu:24.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libelf1 \
    zlib1g \
    libedit2 \
    libssl3 \
    libdw1 \
    libseccomp2 \
    libbpfcc-dev \
    bpfcc-tools \
    kmod \
    procps \
    ca-certificates \
    clang-18 \
    libclang-18-dev \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the built bpftrace binary and its dependencies from the builder stage
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbpf* /usr/lib/x86_64-linux-gnu/

# Set the working directory for the runtime stage
WORKDIR /usr/local/bedrock

# Copy the bpftrace scripts and kernel support check script to the runtime image
COPY bpftrace/ tests/bt_scripts.sh tests/kernel_support.sh ./

CMD ["/bin/bash"]