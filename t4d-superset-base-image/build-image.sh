#!/bin/bash
# Build multi-platform Docker image for linux/amd64 and linux/arm64
# Note: Multi-platform builds require --push (cannot load to local Docker)
docker buildx build --platform linux/amd64,linux/arm64 -t tech4dev/superset:6.1.0 --push .
if [ "$?" -eq 0 ]; then
    echo "Docker image tech4dev/superset:6.1.0 built and pushed successfully for linux/amd64 and linux/arm64!"
else
    echo "Error: Docker image tech4dev/superset:6.1.0 failed to build."
    exit 1
fi
