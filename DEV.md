# Development Guide

Right after bpftrace stopped supporting compile arguments, we had to switch to **Python** and **Jinja2** to build the `bpftrace.bt` scripts.

## File Structure

The `templates/` directory is where all Jinja templates are located.

- `bpftrace/v*` : for each version there are three different tracing methods (VFS, I/O, and Memory).
- `tracers/` : for each type of tracer (cgroup, pid, command, etc.), there is a begin template and filter.

To generate templates into `bpftrace` directory, you must run `python3 gen_bpftrace.py`.

> NOTE: Make sure to have `tracers.json` that contains the template generator parameters.

## Test

After generating new templates, make sure to run the `tests/bt_scripts.sh` script. It will check the compile issues using bpftrace dry-run feature.

```sh
root@c903e3231dfb:/usr/local/bedrock# ./bt_scripts.sh bpftrace/
[INFO] Starting recursive bpftrace dry-run tests
[INFO] Base directory: bpftrace/
[INFO] Total .bt scripts found: 60
[INFO][1/60] Testing: bpftrace/pid/v0/io_trace.bt
[INFO][2/60] Testing: bpftrace/pid/v0/headless_memory_trace.bt
[INFO][3/60] Testing: bpftrace/pid/v0/headless_io_trace.bt
[INFO][4/60] Testing: bpftrace/pid/v0/vfs_trace.bt
....
[INFO][59/60] Testing: bpftrace/execute/v1/memory_trace.bt
[INFO][60/60] Testing: bpftrace/execute/v1/headless_vfs_trace.bt
[SUCCESS] All .bt scripts passed successfully.
```
