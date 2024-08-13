#!/bin/bash

# eg-> ./generate_dockerFiles.sh "client1" "apache/superset:3.1.3" "tech4dev/superset3:0.2" "./output/client1"
# Ensure the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <client_name> <base_image> <superset_image> <output_directory>"
    exit 1
fi

# Assign input parameters to variables
CLIENT_NAME=$1
BASE_IMAGE=$2
SUPERSET_IMAGE=$3
OUTPUT_DIR=$4

# Define a unique container name using the client name
SUPERSET_CONTAINER_NAME="superset-${CLIENT_NAME}"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Generate the Dockerfile by replacing placeholders in Dockerfile.template
sed "s|{{BASE_IMAGE}}|$BASE_IMAGE|g" Dockerfile.template > $OUTPUT_DIR/Dockerfile

# Generate the docker-compose.yml by replacing placeholders in docker-compose.yml.template
sed -e "s|{{SUPERSET_IMAGE}}|$SUPERSET_IMAGE|g" \
    -e "s|{{SUPERSET_CONTAINER_NAME}}|$SUPERSET_CONTAINER_NAME|g" \
    docker-compose.yml.template > $OUTPUT_DIR/docker-compose.yml

# Notify the user of successful generation
echo "Generated Dockerfile and docker-compose.yml for client $CLIENT_NAME in $OUTPUT_DIR"
