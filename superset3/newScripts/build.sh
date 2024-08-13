#!/bin/bash

# Define the output image name and tag
OUTPUT_IMAGE="tech4dev/superset:0.4"

# Build the Docker image
docker build --tag $OUTPUT_IMAGE .

echo "Docker image $OUTPUT_IMAGE built successfully."
