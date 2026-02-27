# Bedrock BPFtrace

**Bedrock BPFtrace** is the repository that contains bpftrace scripts used by the Bedrock tracer. All tracing scripts are generated using Python and Jinja2 templates. Tracing files are exported in `.bt` format. They can also be used directly by `bpftrace` cli. But, the main role of this repository is for [/amirhnajafiz/bedrock-tracer](https://github.com/amirhnajafiz/bedrock-tracer) that clones this repositroy to use it within it's tracing logic.

## Requirements

Make sure to have the following tools installed on your machine if you plan to use the bt scripts with `bpftrace` cli.

* libbpf v1.5.0+
* bpftrace v0.24.0+
* python3
* python3-venv

However, for easier compatibility, we have a Dockerfile that you can build and use to not messup your system environemnt. You can use the `tests/docker_build.sh` as an example to build the image and use it. As future task, we might add a docker image globaly to use Bedrock BPFTrace in containers.

## Overview

This repository contains the BPFtrace programs required for Bedrock’s tracing engine. Templates are written in Python using Jinja2 and compiled into ready-to-run .bt scripts.

## Installation & Script Generation

The bt scripts exist in `bpftrace` directory. So you don't actully need to setup anything if yo have all the requirements. But if you need to have full dependencies to rewrite the scripts or run them on your platform follow next two steps.

### with requirements

After cloning the repository, setup requiresments and regenerate the tracing scripts with:

```sh
make setup
make
```

> Make sure to have Python3 and Python-venv installed on your machine.

### without requirements

If you don't want to have libbpf and bpftrace install, you can just regenerate the scripts:

```sh
make
```

Once completed, the generated .bt files will be available in the bpftrace/ directory.

## Script Categories

The repository generates tracing scripts across five categories:

* Tracing by PID
* Tracing by process name (command)
* Execute and trace a command
* Tracing by cgroup
* Tracing by process name within a cgroup

Each category includes two tracing modes:

1. Basic I/O tracing: Tracks standard I/O operations such as read and write.
2. Memory-mapped I/O tracing: Tracks I/O operations performed via memory mapping.

### Silent Mode

A silent mode is also available. When enabled, metadata collection is omitted to reduce log volume. This mode is useful for high-level I/O monitoring where detailed file access patterns are not required.

## Tracing Events

Read more about the tracing events in [EVENTS.md](EVENTS.md).

## Format

The output logs have the following format:

```txt
[timestamp] {pid=[pid] tid=[tid] proc=[command]}{[EN|EX] [operand]}{[key=value]}
```
