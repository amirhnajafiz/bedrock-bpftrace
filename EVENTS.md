# 📡 Tracing Events

Bedrock Tracer relies on a collection of **kernel tracepoints** and **syscalls** to observe process activity and I/O behavior. Among them, only **cgroup-based tracers** do not require child-process tracing tracepoints.

## 🗂️ File System Probes

These probes hook directly into the Linux Virtual File System (VFS) layer for coarse-grained file activity inspection:

- **vfs_read** — Reads data from a file system.  
- **vfs_write** — Writes data into a file system.

## 💾 I/O Operation Syscalls

These system calls capture low-level read/write events across file descriptors, supporting both standard and vectorized operations:

- **read** — Reads data from a file descriptor into a buffer.  
- **write** — Writes data from a buffer to a file descriptor.  
- **readv** — Reads data into multiple buffers (vectorized I/O).  
- **writev** — Writes data from multiple buffers (vectorized I/O).  
- **pread64** — Reads data from a specific file offset without advancing the file position.  
- **pwrite64** — Writes data to a specific file offset without advancing the file position.  
- **preadv** — Reads data at a given offset into multiple buffers.  
- **pwritev** — Writes data at a given offset from multiple buffers.

## 🧠 Memory Operation Syscalls

Memory operations provide insight into how processes map memory regions and handle page faults:

- **mmap** — Maps files or devices into memory, returning a pointer to the mapped area.  
- **munmap** — Unmaps a region of memory previously mapped with `mmap`.  
- **page_fault_user** — Handles user-mode page faults when a memory page is missing.  
- **handle_mm_fault** — Kernel function responsible for resolving memory page faults.

## 🧱 Metadata Extraction Syscalls

These syscalls are used to trace file metadata access, descriptor management, and file statistics retrieval:

- **open** — Opens or creates a file and returns a file descriptor.  
- **openat** — Opens or creates a file relative to a directory descriptor.  
- **dup** — Duplicates an existing file descriptor to the lowest-numbered unused descriptor.  
- **dup2** — Duplicates an existing file descriptor to a given target descriptor.  
- **dup3** — Duplicates a file descriptor with extra flags (e.g., `O_CLOEXEC`).  
- **statfs** — Returns file system statistics for a file or mount point.  
- **statx** — Retrieves extended status information about a file.  
- **newlstat** — Gets file info without following symbolic links (variant of `lstat`).  
- **newstat** — Retrieves file status information (variant of `stat`).  
- **creat** — Creates or truncates a file (equivalent to `open` with `O_CREAT|O_WRONLY|O_TRUNC`).  
- **close** — Closes a file descriptor and frees related kernel resources.

## 👶 Child Process Tracing Syscalls

These syscalls are required for complete process lifecycle tracking and child inheritance events:

- **fork** — Creates a new process by duplicating the calling process.  
- **exec** — Replaces the current process image with a new program image.

📘 **Note:**

I/O tracepoint selection directly impacts tracing overhead and granularity. Adjust probe sets depending on your observability depth and system load tolerance.
