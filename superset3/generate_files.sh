#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <client_name> <superset_version> <output_directory>"
    exit 1
fi

# Assign input parameters to variables
CLIENT_NAME=$1
SUPERSET_VERSION=$2
OUTPUT_DIR=$3

# Define the image name and container name based on client name and version
SUPERSET_IMAGE="tech4dev/superset:${SUPERSET_VERSION}"
SUPERSET_CONTAINER_NAME="superset-${CLIENT_NAME}"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Generate the Dockerfile by replacing placeholders in Dockerfile.template
sed "s|{{BASE_IMAGE}}|$SUPERSET_IMAGE|g" Dockerfile.template > $OUTPUT_DIR/Dockerfile

# Generate the docker-compose.yml by replacing placeholders in docker-compose.yml.template
sed -e "s|{{SUPERSET_IMAGE}}|$SUPERSET_IMAGE|g" \
    -e "s|{{SUPERSET_CONTAINER_NAME}}|$SUPERSET_CONTAINER_NAME|g" \
    docker-compose.yaml.template > $OUTPUT_DIR/docker-compose.yml

# Notify the user of the successful generation
echo "Generated Dockerfile and docker-compose.yml for client: $CLIENT_NAME in $OUTPUT_DIR"
