variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["bedrock"]
}

target "bedrock" {
  context    = "."
  dockerfile = "build/Dockerfile"

  tags = [
    "ghcr.io/amirhnajafiz/bedrock-bpftrace:${TAG}",
    "ghcr.io/amirhnajafiz/bedrock-bpftrace:latest"
  ]

  output = ["type=registry"]
}
