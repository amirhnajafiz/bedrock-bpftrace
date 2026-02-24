#!/usr/bin/env bash
set -euo pipefail

LIBBPF_VERSION="v1.5.0"
BPFTRACE_VERSION="v0.24.0"

echo "[+] Updating system..."
sudo apt update

echo "[+] Installing dependencies..."
sudo apt install -y \
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
  libssl-dev

# --------------------------------------------------
# Install libbpf 1.5+
# --------------------------------------------------
echo "[+] Installing libbpf ${LIBBPF_VERSION}..."

rm -rf /tmp/libbpf
git clone --branch ${LIBBPF_VERSION} --depth 1 https://github.com/libbpf/libbpf.git /tmp/libbpf

cd /tmp/libbpf/src
make
sudo make install
sudo ldconfig

echo "[+] libbpf installed successfully"

# --------------------------------------------------
# Install bpftrace 0.24
# --------------------------------------------------
echo "[+] Installing bpftrace ${BPFTRACE_VERSION}..."

rm -rf /tmp/bpftrace
git clone --branch ${BPFTRACE_VERSION} --depth 1 https://github.com/bpftrace/bpftrace.git /tmp/bpftrace

cd /tmp/bpftrace
mkdir build && cd build

cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo make install

sudo ldconfig

echo "[+] Installation complete!"
echo "[+] Verifying versions..."

echo "libbpf version:"
pkg-config --modversion libbpf

echo "bpftrace version:"
bpftrace --version
