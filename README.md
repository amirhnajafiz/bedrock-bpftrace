# Bedrock BPFtrace

[![License](https://img.shields.io/github/license/amirhnajafiz/bedrock-bpftrace?color=blue)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/amirhnajafiz/bedrock-bpftrace)](https://github.com/amirhnajafiz/bedrock-bpftrace/releases)
[![Latest Tag](https://img.shields.io/github/v/tag/amirhnajafiz/bedrock-bpftrace)](https://github.com/amirhnajafiz/bedrock-bpftrace/tags)

**Bedrock BPFtrace** provides ready-to-use and templated [BPFtrace](https://github.com/iovisor/bpftrace) scripts used by the [Bedrock Tracer](https://github.com/amirhnajafiz/bedrock-tracer). All scripts are generated from **Python (Jinja2)** templates and compiled into `.bt` tracing programs.

## ✨ Overview

Bedrock BPFtrace delivers the dynamic tracing layer for Bedrock’s observability stack, offering rich visibility into file system, network, and process-level I/O.  

Scripts are auto-generated and located under the `bpftrace/` directory, making them compatible with the `bpftrace` CLI or Bedrock Tracer runtime.

## 🧰 Requirements

To use `.bt` scripts directly with `bpftrace`, install:

- **libbpf** ≥ v1.5.0  
- **bpftrace** ≥ v0.24.0  
- **python3**  
- **python3-venv**

### Install on Linux

If you have an Ubuntu 24.04 machine, then you can run `install-bpftrace.sh` script to have **bpftrace** and **libbpf** installed.

> WARN: This script may not work on all Linux machines/kernels. Using the docker image would be a safer solution.

### Using with Docker

The Bedrock BPFtrace has a base docker image that you can use. It already has **bpftrace**, **libbpf**, and **python3** installed.

The container needs a host that supports eBPF (prefer BTF-enabled kernels). Also it requires privilege access to trace host processes.

```sh
docker run \
    --privileged \
    --pid=host \ 
    -v /sys:/sys -v /lib/modules:/lib/modules \
    -it ghcr.io/amirhnajafiz/bedrock-bpftrace:latest
```

> WARN: This may exploit security risks.

#### local docker image build

Alternatively, you can use the included **Docker environment** for isolated builds.

```bash
# Build Docker image for Bedrock BPFtrace
bash tests/docker_build.sh
```

### Kernel Support

To check if your machine is capable of running the bpftrace scripts, you can run the following kernel support check script:

```sh
$ sudo ./tests/kernel_support.sh
[INFO] Kernel: 6.8.0-101-generic
[OK] BTF detected
[SUCCESS] Host is capable of running bpftrace scripts
```

The test scripts are also embedded in the docker image. You can find them under `/usr/local/bedrock` directory.

> NOTE: When you run the container in privileged mode, you don't need to run these tests with `sudo`.

## ⚙️ Installation & Script Generation

Scripts are already pre-generated under `bpftrace/`.  
If you want to modify templates or regenerate everything, choose one of the options below:

### Option 1 — Full setup (with all dependencies)

```bash
make setup
make
```

> Ensure Python 3 and `python3-venv` are installed.

### Option 2 — Lightweight regeneration (no system dependencies)

```bash
make
```

After successful execution, all generated `.bt` files will appear in `bpftrace/`.

## 🔍 Script Categories

Bedrock BPFtrace generates tracing scripts across the following categories:

- Trace by **PID**
- Trace by **process name (command)**
- **Execute and trace** a command
- Trace by **cgroup**
- Trace by **process name within a cgroup**

Each category supports multiple tracing types:

1. **File System I/O Tracing** — High-level VFS read/write tracking.  
2. **Basic I/O Tracing** — Standard read/write tracing with file path visibility (moderate overhead).  
3. **Memory-Mapped I/O Tracing** — Detailed operations via memory mapping (higher overhead, verbose output).

## 🧠 Headless Mode

A **headless mode** is available for reduced log size and overhead.  
In this mode, metadata collection is skipped—useful for system-wide I/O summaries and performance-focused tracing runs.

## 🪶 Log Format

The output produced by BPFtrace scripts follows a structured format for easy parsing.

### V0 (old version)

It requires grouping EN and EX entires.

```text
[timestamp] {pid=[pid] tid=[tid] proc=[command]} { [EN|EX] [operand] } { [key=value], }
```

Example:

```text
[171243.918] {pid=4123 tid=4123 proc=nginx}{EN read}{fd=5, fname=/var/log/access.log}
[171245.200] {pid=4123 tid=4123 proc=nginx}{EX read}{ret=500}
```

### V1

By using ebpf maps, it groups the EN and EX events inside the bpftrace script.

```text
[timestamp] {pid=[pid] tid=[tid] proc=[command]} { [operand] } { [key=value], }
```

Example:

```text
[171245.200] {pid=4123 tid=4123 proc=nginx}{read}{fd=5, fname=/var/log/access.log, duration=11, ret=500}
```

### Common Keys

Here is a list of keys that you will get as `[key=value]` pairs.

- `fname` : file name (could be absolute path too)
- `ret` : return value
- `fd` : file descriptor
- `count` : number of data bytes
- `duration` : latency in nano-seconds
- `addr` : memory address

## 📚 Tracing Events

A detailed specification of all event types is available in [EVENTS.md](EVENTS.md).

## 🧩 Related Projects

- [Bedrock Tracer](https://github.com/amirhnajafiz/bedrock-tracer) — Core tracing engine using Bedrock BPFtrace scripts.
- [bpftrace](https://github.com/iovisor/bpftrace) — BPF-based tracing CLI tool built on libbpf.

## 🤝 Contributing

Contributions are welcome! Fork this repository, open a pull request, or file an issue to report bugs or request new features.

Please follow the project’s code and documentation style for consistency.

## 📄 License

This project is licensed under the [Apache License](LICENSE).
