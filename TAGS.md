# Tags

This project maintains two independent version streams with separate tag formats:

| Tag format | Targets          | Description                                           |
|------------|------------------|-------------------------------------------------------|
| `v*.*.*`   | Docker image     | Versions the base image (bpftrace + libbpf + python3) |
| `s*.*.*`   | BPFtrace scripts | Versions the generated `.bt` scripts in `bpftrace/`   |

## Why two streams?

The Docker image is versioned independently from the scripts because the image only provides the runtime environment — it does not bundle the scripts directly. As a result, a newer image tag may ship with an older set of scripts, and vice versa.

For best results, always pair the Docker image with the latest scripts tag:

```sh
# Pull the latest base image
docker pull ghcr.io/amirhnajafiz/bedrock-bpftrace:latest

# Check out the latest scripts tag separately
git checkout $(git tag -l 's*.*.*' | sort -V | tail -1)

# Run by mounting the latest scripts
docker run -v /usr/local/bedrock/bpftrace:./bpftrace ghcr.io/amirhnajafiz/bedrock-bpftrace:latest
```

## Checking available tags

```sh
# List all image tags
git tag -l 'v*.*.*' | sort -V

# List all script tags
git tag -l 's*.*.*' | sort -V
```
