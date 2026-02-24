FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBBPF_VERSION=v1.5.0
ENV BPFTRACE_VERSION=v0.24.0

# Install dependencies
RUN apt-get update && apt-get install -y \
    linux-tools-generic \
    linux-tools-common \
    linux-headers-generic \
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

# -----------------------------
# Build and install libbpf
# -----------------------------
RUN git clone --branch ${LIBBPF_VERSION} --depth 1 https://github.com/libbpf/libbpf.git /tmp/libbpf && \
    cd /tmp/libbpf/src && \
    make && \
    make install PREFIX=/usr LIBDIR=/usr/lib/x86_64-linux-gnu && \
    ldconfig && \
    rm -rf /tmp/libbpf

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

WORKDIR /usr/local/app

COPY bpftrace/ bpftrace/
COPY tests/bt_scripts.sh bt_scripts.sh

# Default command
CMD ["./bt_scripts.sh", "/usr/local/app/bpftrace"]
