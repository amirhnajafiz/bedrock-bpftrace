# ============================
# Stage 1 — Builder
# ============================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBBPF_VERSION=v1.5.0
ENV BPFTRACE_VERSION=v0.24.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    cmake \
    clang-18 \
    llvm-18 \
    llvm-18-dev \
    libclang-18-dev \
    flex \
    bison \
    pkg-config \
    libelf-dev \
    zlib1g-dev \
    libfl-dev \
    libedit-dev \
    libssl-dev \
    libdw-dev \
    libcereal-dev \
    pahole \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# Build libbpf
RUN git clone --depth 1 --branch ${LIBBPF_VERSION} \
    https://github.com/libbpf/libbpf.git /tmp/libbpf && \
    make -C /tmp/libbpf/src -j$(nproc) && \
    make -C /tmp/libbpf/src install PREFIX=/usr LIBDIR=/usr/lib/x86_64-linux-gnu && \
    rm -rf /tmp/libbpf

# Build bpftrace
RUN git clone --depth 1 --branch ${BPFTRACE_VERSION} \
    https://github.com/bpftrace/bpftrace.git /tmp/bpftrace && \
    cmake -S /tmp/bpftrace -B /tmp/bpftrace/build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /tmp/bpftrace/build -j$(nproc) && \
    cmake --install /tmp/bpftrace/build && \
    strip /usr/local/bin/bpftrace && \
    rm -rf /tmp/bpftrace


# ============================
# Stage 2 — Runtime
# ============================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libelf1 \
    zlib1g \
    libedit2 \
    libssl3 \
    libdw1 \
    libseccomp2 \
    kmod \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbpf* /usr/lib/x86_64-linux-gnu/

WORKDIR /usr/local/app

COPY bpftrace/ bpftrace/
COPY tests/bt_scripts.sh bt_scripts.sh

CMD ["./bt_scripts.sh", "/usr/local/app/bpftrace"]
