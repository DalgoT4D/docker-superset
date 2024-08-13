#!/bin/bash

# Define the output image name and tag
OUTPUT_IMAGE="tech4dev/superset:0.4"

# Push the Docker image to DockerHub
docker push $OUTPUT_IMAGE

echo "Docker image $OUTPUT_IMAGE pushed to DockerHub successfully."
