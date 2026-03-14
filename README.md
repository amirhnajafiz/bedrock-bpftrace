# Bedrock BPFtrace

[![License](https://img.shields.io/github/license/amirhnajafiz/bedrock-bpftrace?color=blue)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/amirhnajafiz/bedrock-bpftrace)](https://github.com/amirhnajafiz/bedrock-bpftrace/releases)
[![Latest Tag](https://img.shields.io/github/v/tag/amirhnajafiz/bedrock-bpftrace)](https://github.com/amirhnajafiz/bedrock-bpftrace/tags)
![Image Size](https://img.shields.io/badge/image_size-861_MB-blue)

**Bedrock BPFtrace** provides ready-to-use, templated [BPFtrace](https://github.com/iovisor/bpftrace) scripts for the [Bedrock Tracer](https://github.com/amirhnajafiz/bedrock-tracer). Scripts are generated from **Jinja2** templates via Python and compiled into `.bt` tracing programs targeting the Linux kernel.

---

## Table of Contents

- [Bedrock BPFtrace](#bedrock-bpftrace)
  - [Table of Contents](#table-of-contents)
  - [✨ Overview](#-overview)
  - [🧰 Requirements](#-requirements)
    - [Running scripts directly with `bpftrace`](#running-scripts-directly-with-bpftrace)
  - [🚀 Setup](#-setup)
    - [Linux (native)](#linux-native)
    - [Docker](#docker)
    - [Kernel support check](#kernel-support-check)
  - [⚙️ Script Generation](#️-script-generation)
  - [🔍 Script Categories](#-script-categories)
    - [Filter targets](#filter-targets)
    - [Tracing types](#tracing-types)
  - [🧠 Headless Mode](#-headless-mode)
  - [🪶 Log Format](#-log-format)
    - [V0](#v0)
    - [V1](#v1)
    - [Common field reference](#common-field-reference)
  - [📚 Tracing Events](#-tracing-events)
  - [🧩 Related Projects](#-related-projects)
  - [🤝 Contributing](#-contributing)
  - [📄 License](#-license)

---

## ✨ Overview

Bedrock BPFtrace is the dynamic tracing layer of Bedrock's observability stack. It provides deep visibility into file system I/O, memory-mapped operations, and process-level activity by hooking into the Linux kernel through eBPF.

Pre-generated scripts live under `bpftrace/` and are compatible with either the `bpftrace` CLI or the Bedrock Tracer runtime. Each script is produced from a versioned Jinja2 template, so output format and probe selection can be extended without modifying individual `.bt` files.

---

## 🧰 Requirements

### Running scripts directly with `bpftrace`

| Dependency   | Minimum version |
|--------------|-----------------|
| libbpf       | v1.5.0          |
| bpftrace     | v0.24.0         |
| python3      | —               |
| python3-venv | —               |

A BTF-enabled kernel is strongly recommended (kernel ≥ 5.8).

---

## 🚀 Setup

### Linux (native)

On **Ubuntu 24.04**, run the provided installation script to install `bpftrace` and `libbpf`:

```sh
bash install-bpftrace.sh
```

> **Warning:** This script targets Ubuntu 24.04. On other distributions or kernel versions, manual installation is recommended. Using the Docker image is the safer alternative.

### Docker

A pre-built Docker image is available with `bpftrace`, `libbpf`, and `python3` already installed. The container requires a BTF-enabled host kernel and privileged access to trace host processes.

```sh
docker run --rm \
    --privileged \
    --pid=host \
    -v /sys:/sys \
    -v /lib/modules:/lib/modules \
    -it ghcr.io/amirhnajafiz/bedrock-bpftrace:latest
```

> **Warning:** Running a container in privileged mode grants it full access to the host. Only do this in trusted environments.

To build the image locally instead:

```sh
bash tests/docker_build.sh
```

The image embeds the following utilities under `/usr/local/bedrock/`:

| File / Directory    | Purpose                                |
|---------------------|----------------------------------------|
| `bpftrace/`         | Pre-generated Bedrock BPFtrace scripts |
| `bt_scripts.sh`     | Dry-run testing for all `.bt` scripts  |
| `kernel_support.sh` | Host kernel compatibility check        |

> **Note:** No `sudo` is needed when the container runs in privileged mode.

### Kernel support check

Before running any script, verify that your kernel supports eBPF tracing:

```sh
sudo ./tests/kernel_support.sh
```

Expected output on a supported system:

```text
[INFO] Kernel: 6.8.0-101-generic
[OK] BTF detected
[SUCCESS] Host is capable of running bpftrace scripts
```

---

## ⚙️ Script Generation

Pre-generated scripts are already present in `bpftrace/` and can be used immediately. To modify templates or regenerate scripts from scratch:

**Full setup** (installs Python dependencies into a virtual environment):

```sh
make setup
make
```

**Regenerate only** (when dependencies are already installed):

```sh
make
```

After a successful run, all `.bt` files are written to `bpftrace/`.

For details on the template system and how to add new tracers, see [DEV.md](DEV.md).

---

## 🔍 Script Categories

Scripts are organized by the *target* they filter on and the *tracing type* they apply.

### Filter targets

| Directory             | Filters on                             |
|-----------------------|----------------------------------------|
| `pid/`                | Process ID                             |
| `command/`            | Process name                           |
| `execute/`            | Spawned command (executes then traces) |
| `cgroup/`             | Control group                          |
| `cgroup_and_command/` | Process name within a cgroup           |

### Tracing types

Each filter target produces three script variants:

| Script            | Tracing type                 | Overhead |
|-------------------|------------------------------|----------|
| `vfs_trace.bt`    | VFS-level I/O (read/write)   | Low      |
| `io_trace.bt`     | Syscall I/O with file path   | Moderate |
| `memory_trace.bt` | Memory-mapped I/O operations | High     |

Each variant also has a `headless_` prefixed counterpart (see [Headless Mode](#-headless-mode)).

Script versions (`v0/`, `v1/`) correspond to different log output formats (see [Log Format](#-log-format)).

---

## 🧠 Headless Mode

Headless scripts (`headless_*.bt`) skip metadata collection (file names, process names, etc.), producing minimal output. Use them when:

- You need system-wide I/O throughput summaries.
- Metadata collection overhead is unacceptable.
- Log volume must be kept small.

---

## 🪶 Log Format

All scripts emit structured, line-oriented log records for easy parsing.

### V0

Entry (`EN`) and exit (`EX`) events are emitted as separate lines and must be correlated by `pid`/`tid` during post-processing.

**Format:**

```text
[timestamp] {pid=[pid] tid=[tid] proc=[command]}{EN|EX [operand]}{[key=value], ...}
```

**Example:**

```text
[171243.918] {pid=4123 tid=4123 proc=nginx}{EN read}{fd=5, fname=/var/log/access.log}
[171245.200] {pid=4123 tid=4123 proc=nginx}{EX read}{ret=500}
```

### V1

Entry and exit events are merged inside the BPF program using eBPF maps, eliminating the need for client-side correlation.

**Format:**

```text
[timestamp] {pid=[pid] tid=[tid] proc=[command]}{[operand]}{[key=value], ...}
```

**Example:**

```text
[171245.200] {pid=4123 tid=4123 proc=nginx}{read}{fd=5, fname=/var/log/access.log, duration=11, ret=500}
```

### Common field reference

| Key        | Description                      |
|------------|----------------------------------|
| `fname`    | File name or absolute path       |
| `fd`       | File descriptor                  |
| `ret`      | System call return value         |
| `count`    | Number of bytes transferred      |
| `duration` | Call latency in nanoseconds      |
| `addr`     | Memory address (memory ops only) |

---

## 📚 Tracing Events

A full specification of all kernel probes and syscalls used by each script type is available in [EVENTS.md](EVENTS.md).

---

## 🧩 Related Projects

| Project                                                          | Description                                                |
|------------------------------------------------------------------|------------------------------------------------------------|
| [Bedrock Tracer](https://github.com/amirhnajafiz/bedrock-tracer) | Core tracing engine that consumes Bedrock BPFtrace scripts |
| [bpftrace](https://github.com/iovisor/bpftrace)                  | BPF-based high-level tracing language and CLI              |

---

## 🤝 Contributing

Contributions are welcome. To get started:

1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with a clear description of your changes.

For template conventions, script naming rules, and testing procedures, refer to [DEV.md](DEV.md).

---

## 📄 License

This project is licensed under the [Apache 2.0 License](LICENSE).
